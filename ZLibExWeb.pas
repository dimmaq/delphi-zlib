unit ZLibExWeb;

interface

{$I jedi.inc}
{$I ZLibEx.inc}

{$IFNDEF DELPHIXE_UP}
type
  RawByteString = AnsiString;
{$ENDIF}

function ZDecompressWeb(const ABuffer: RawByteString): RawByteString;

implementation

uses
  Windows, SysUtils, Classes,
  //
  ZLibEx, ZLibExApi;

{
https://stackoverflow.com/questions/1838699/how-can-i-decompress-a-gzip-stream-with-zlib

***choosing windowBits ***
But zlib can decompress all those formats:

to (de-)compress deflate format, use wbits = -zlib.MAX_WBITS
to (de-)compress zlib format, use wbits = zlib.MAX_WBITS
to (de-)compress gzip format, use wbits = zlib.MAX_WBITS | 16
See documentation in http://www.zlib.net/manual.html#Advanced (section inflateInit2)

***automatic header detection (zlib or gzip)***
adding 32 to windowBits will trigger header detection
}
const
  MAX_WBITS = 15; {/* 32K LZ77 window */}
  ZLIB_DECODE_AUTO_WINDOWBITS = MAX_WBITS or 32;
  ZLIB_DECODE_GZIP_WINDOWBITS = MAX_WBITS or 16;

function ZDecompressWeb(const ABuffer: RawByteString): RawByteString;
var
  gz: TZDecompressionStream;
  sout, sin: TMemoryStream;
begin
  Result := '';
  sin := nil;
  gz := nil;
  sout := nil;
  try
    sin := TMemoryStream.Create();
    sin.WriteBuffer(Pointer(ABuffer)^, Length(ABuffer));
    gz := TZDecompressionStream.Create(sin, ZLIB_DECODE_AUTO_WINDOWBITS);
    sout := TMemoryStream.Create;
    sout.CopyFrom(gz, 0);
    SetLength(Result, sout.Size);
    Move(sout.Memory^, Result[1], sout.Size);
  finally
    gz.Free;
    sout.Free;
    sin.Free;
  end;

end;

end.
