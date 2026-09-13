import 'dart:convert';
import 'dart:typed_data';

import 'package:archive/archive.dart';
import 'package:xml/xml.dart';

/// excel 4.x searches qualified XML names instead of their namespace URI.
/// Normalize equivalent prefixed OOXML in memory; never edit the user's file.
Uint8List normalizeExcelNamespaces(Uint8List bytes) {
  const namespaces = {
    'http://schemas.openxmlformats.org/spreadsheetml/2006/main',
    'http://schemas.openxmlformats.org/package/2006/relationships',
    'http://schemas.openxmlformats.org/package/2006/content-types',
  };
  final archive = ZipDecoder().decodeBytes(bytes);
  final normalized = Archive();
  var changed = false;
  for (final entry in archive.files) {
    if (!entry.isFile ||
        !(entry.name.endsWith('.xml') || entry.name.endsWith('.rels'))) {
      normalized.addFile(entry);
      continue;
    }
    final document = XmlDocument.parse(utf8.decode(entry.content as List<int>));
    final namespace = document.rootElement.namespaceUri;
    final hasPrefixedElements =
        namespaces.contains(namespace) &&
        document.descendants.whereType<XmlElement>().any(
          (node) => node.name.prefix != null && node.namespaceUri == namespace,
        );
    XmlNode copyNode(XmlNode node) {
      if (node is! XmlElement) return node.copy();
      return XmlElement(
        node.namespaceUri == namespace
            ? XmlName(node.name.local)
            : node.name.copy(),
        node.attributes.map((attribute) => attribute.copy()),
        node.children.map(copyNode),
        node.isSelfClosing,
      );
    }

    final result = hasPrefixedElements
        ? XmlDocument(document.children.map(copyNode))
        : document;
    var entryChanged = hasPrefixedElements;
    if (hasPrefixedElements) {
      result.rootElement.setAttribute('xmlns', namespace!);
    }
    // excel 4.x prepends xl/ and cannot resolve package-absolute targets.
    if (entry.name == 'xl/_rels/workbook.xml.rels') {
      for (final node in result.descendants.whereType<XmlElement>()) {
        final target = node.getAttribute('Target');
        if (node.name.local == 'Relationship' &&
            node.namespaceUri ==
                'http://schemas.openxmlformats.org/package/2006/relationships' &&
            node.getAttribute('TargetMode') != 'External' &&
            target != null &&
            target.startsWith('/xl/')) {
          node.setAttribute('Target', target.substring(4));
          entryChanged = true;
        }
      }
    }
    if (!entryChanged) {
      normalized.addFile(entry);
      continue;
    }
    final content = utf8.encode(result.toXmlString());
    normalized.addFile(ArchiveFile(entry.name, content.length, content));
    changed = true;
  }
  return changed ? Uint8List.fromList(ZipEncoder().encode(normalized)!) : bytes;
}
