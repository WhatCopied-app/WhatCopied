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

  NSMutableString *result = [NSMutableString stringWithCapacity:length * 4];
  NSMutableData *lineBuffer = [NSMutableData dataWithLength:(bytesPerRow * 3 - 1) + bytesPerRow + 20];
  char *line = (char *)lineBuffer.mutableBytes;

  for (NSUInteger i = 0; i < length; i += bytesPerRow) {
    // Offset column
    snprintf(line, 10, "%08ld:", (unsigned long)i);
    char *cursor = line + 9;

    // Hex column
    NSUInteger rowLength = MIN(bytesPerRow, length - i);
    for (NSUInteger j = 0; j < rowLength; j++) {
      snprintf(cursor, 4, " %02X", bytes[i + j]);
      cursor += 3;
    }

    if (rowLength < bytesPerRow) {
      NSUInteger padding = (bytesPerRow - rowLength) * 3;
      memset(cursor, ' ', padding);
      cursor += padding;
    }

    // ASCII column
    *cursor++ = ' ';
    *cursor++ = ' ';
    for (NSUInteger j = 0; j < rowLength; j++) {
      uint8_t byte = bytes[i + j];
      BOOL useByte = (byte >= 32 && byte < 127) || (byte >= 160 && byte < 255);
      *cursor++ = useByte ? (char)byte : '.';
    }

    *cursor++ = '\n';
    *cursor = '\0';
    [result appendFormat:@"%s", line];
  }

  return result;
}
