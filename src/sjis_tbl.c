// sjis_tbl - generate Shift_JIS table

// This file is part of Xperiment68k
// Copyright (C) 2022 TcbnErik
//
// This program is free software: you can redistribute it and/or modify
// it under the terms of the GNU General Public License as published by
// the Free Software Foundation, either version 3 of the License, or
// (at your option) any later version.
//
// This program is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
// GNU General Public License for more details.
//
// You should have received a copy of the GNU General Public License
// along with this program.  If not, see <https://www.gnu.org/licenses/>.

#include <stdio.h>
#include <string.h>

static void PrintLineDbhw(int lead_byte, int from, int to) {
  int tb;

  printf("%02x%02x: ", lead_byte, from);
  for (tb = from; tb <= to; ++tb) {
    if (tb == from + 16) {
      putchar(' ');
      putchar(' ');
    }
    if (tb == 0) {
      putchar('*');
      putchar('*');
    } else {
      putchar(' ');
      putchar(lead_byte);
      putchar(tb);
    }
  }
  puts("");
}

static void PrintLine(int lead_byte, int from, int to) {
  int tb;

  printf("%02x%02x: ", lead_byte, from);
  for (tb = from; tb <= to; ++tb) {
    if (tb == from + 16) {
      putchar(' ');
      putchar(' ');
    }
    putchar(lead_byte);
    putchar(tb);
  }
  puts("");
}

static void PrintBlock(int lead_byte) {
  puts(
      "      "
      "+0+1+2+3+4+5+6+7+8+9+a+b+c+d+e+f  "
      "+0+1+2+3+4+5+6+7+8+9+a+b+c+d+e+f");

  if (lead_byte >= 0xf4) {
    PrintLineDbhw(lead_byte, 0x20, 0x3f);
    PrintLineDbhw(lead_byte, 0x40, 0x5f);
    PrintLineDbhw(lead_byte, 0x60, 0x7f);
    PrintLineDbhw(lead_byte, 0x80, 0x9f);
    PrintLineDbhw(lead_byte, 0xa0, 0xbf);
    PrintLineDbhw(lead_byte, 0xc0, 0xdf);
    PrintLineDbhw(lead_byte, 0xe0, 0xff);
  } else if (lead_byte >= 0xf0) {
    PrintLineDbhw(lead_byte, 0x20, 0x3f);
    PrintLineDbhw(lead_byte, 0x40, 0x5f);
    PrintLineDbhw(lead_byte, 0x60, 0x7e);
    PrintLineDbhw(lead_byte, 0xa0, 0xbf);
    PrintLineDbhw(lead_byte, 0xc0, 0xdf);
  } else {
    PrintLine(lead_byte, 0x40, 0x5f);
    PrintLine(lead_byte, 0x60, 0x7e);
    PrintLine(lead_byte, 0x80, 0x9f);
    PrintLine(lead_byte, 0xa0, 0xbf);
    PrintLine(lead_byte, 0xc0, 0xdf);
    PrintLine(lead_byte, 0xe0, 0xfc);
  }

  puts("");
}

static void PrintBlocks(int from, int to) {
  int lb;
  for (lb = from; lb <= to; ++lb) {
    PrintBlock(lb);
  }
}

int main(int argc, char* argv[]) {
  int switch_f = 0;
  if (argc >= 2 && strcmp(argv[1], "f") == 0) {
    switch_f = 1;
  }

  if (switch_f) {
    PrintBlocks(0xf0, 0xf5);
  } else {
    PrintBlocks(0x81, 0x9f);
    PrintBlocks(0xe0, 0xef);
  }

  return 0;
}

// EOF
