//
//  HexDump.m
//  WhatCopied
//
//  Created by cyan on 2024/12/5.
//

#import "HexDump.h"

NSString *hexDump(NSData *data, NSUInteger bytesPerRow) {
  const uint8_t *bytes = (const uint8_t *)data.bytes;
  NSUInteger length = data.length;
  NSMutableString *result = [NSMutableString stringWithCapacity:(length / bytesPerRow + 1) * (10 + bytesPerRow * 4)];

  char lineBuffer[1024]; // Enough space for typical rows

  for (NSUInteger i = 0; i < length; i += bytesPerRow) {
    // Offset column
    char *cursor = lineBuffer;
    cursor += snprintf(cursor, sizeof(lineBuffer), "%08ld: ", (unsigned long)i);

    // Hex column
    NSUInteger rowLength = MIN(bytesPerRow, length - i);
    for (NSUInteger j = 0; j < rowLength; j++) {
      cursor += snprintf(cursor, 4, "%02X ", bytes[i + j]);
    }

    if (rowLength < bytesPerRow) {
      memset(cursor, ' ', (bytesPerRow - rowLength) * 3);
      cursor += (bytesPerRow - rowLength) * 3;
    }

    // ASCII column
    *cursor++ = ' ';
    for (NSUInteger j = 0; j < rowLength; j++) {
      uint8_t byte = bytes[i + j];
      *cursor++ = (byte >= 32 && byte < 127) ? (char)byte : '.';
    }

    *cursor++ = '\n';
    *cursor = '\0';
    [result appendString:[NSString stringWithUTF8String:lineBuffer]];
  }

  return result;
}
