;;;;
;;;;
;;;;

(defpackage #:coalton-png
  (:use #:coalton
	#:coalton-prelude)
  (:local-nicknames (#:vec #:coalton-library/vector)))

(in-package #:coalton-png)

;; https://www.w3.org/TR/2003/REC-PNG-20031110/

;; https://en.wikipedia.org/wiki/PNG

;; http://www.libpng.org/pub/png/book/chapter08.html

(coalton-toplevel
  
  (define-struct TrueColorAlpha
    "Truecolour with alpha: each pixel consists of four samples: red, green, blue, and alpha."
    (Red U8)
    (Green U8)
    (Blue U8)
    (Alpha U8))

  (define-instance (Default TrueColorAlpha)
    (define (default)
      (TrueColorAlpha 0 0 0 0)))
  
  (define-struct GreyScaleAlpha
    "Greyscale with alpha: each pixel consists of two samples: grey and alpha."
    (Grey U8)
    (Alpha U8))

  (define-instance (Default GreyscaleAlpha)
    (define (default)
      (GreyscaleAlpha 0 0)))
  
  (define-struct TrueColor
    "Truecolour: each pixel consists of three samples: red, green, and blue. The alpha channel may be represented by a single pixel value. Matching pixels are fully transparent, and all others are fully opaque. If the alpha channel is not represented in this way, all pixels are fully opaque."
    (Red U8)
    (Green U8)
    (Blue U8))

  (define-instance (Default TrueColor)
    (define (default)
      (TrueColor 0 0 0)))

  (define-struct GreyScale
    "Greyscale: each pixel consists of a single sample: grey. The alpha channel may be represented by a single pixel value as in the previous case. If the alpha channel is not represented in this way, all pixels are fully opaque."
    (Grey U8))

  (define-instance (Default GreyScale)
    (define (default)
      (Greyscale 0)))

  (define-struct Indexed-colour
    "Indexed-colour: each pixel consists of an index into a palette (and into an associated table of alpha values, if present)."
    (Index U8)))

;;;
;;; Chunks
;;;

(coalton-toplevel

  (define signature
    (the (Vector U8) (vec:make 137 80 78 71 13 10 26 10)))

  (define-type 4Bytes
    (4Bytes U8 U8 U8 U8))

  (define-instance (Into 4Bytes (Vector U8))
    (define (into (4Bytes a b c d))
      (vec:make a b c d)))
  
  (define-struct Chunk
    (Chunk-Length
     "A four-byte unsigned integer giving the number of bytes in the chunk's data field. The length counts only the data field, not itself, the chunk type, or the CRC. Zero is a valid length. Although encoders and decoders should treat the length as unsigned, its value shall not exceed 231-1 bytes."
     4Bytes)
    (Chunk-Type
     "A sequence of four bytes defining the chunk type. Each byte of a chunk type is restricted to the decimal values 65 to 90 and 97 to 122. These correspond to the uppercase and lowercase ISO 646 letters (A-Z and a-z) respectively for convenience in description and examination of PNG datastreams. Encoders and decoders shall treat the chunk types as fixed binary values, not character strings."
     4Bytes)
    (Chunk-Data
     "The data bytes appropriate to the chunk type, if any. This field can be of zero length."
     (Vector U8))
    (CRC
     "A four-byte CRC (Cyclic Redundancy Code) calculated on the preceding bytes in the chunk, including the chunk type field and chunk data fields, but not including the length field. The CRC can be used to check for corruption of the data. The CRC is always present, even for chunks containing no data. "
     4Bytes))

  (define-type Critical-Chunk
    (IHDR "Shall be first" Chunk)
    (PLTE "Before first IDAT" Chunk)
    (IDAT "Multiple IDAT chunks shall be consecutive" Chunk)
    (IEND "Shall be last" Chunk))


  (define-type Ancillary-Chunk
    (cHRM "Before PLTE and IDAT"                Chunk)
    (gAMA "Before PLTE and IDAT"                                     Chunk)
    (iCCP "Before PLTE and IDAT. 
If the iCCP chunk is present, the sRGB chunk should not be present." Chunk)
    (sBIT "Before PLTE and IDAT"                                     Chunk)
    (sRGB "Before PLTE and IDAT. 
If the sRGB chunk is present, the iCCP chunk should not be present." Chunk)
    ;; the next three don't exist without a palette
    (bKGD "After PLTE; before IDAT"                                  Chunk)
    (hIST "After PLTE; before IDAT"                                  Chunk)
    (tRNS "After PLTE; before IDAT"                                  Chunk)
    (pHYs "Before IDAT"                                              Chunk)
    (sPLT "Before IDAT"                                              Chunk)
    (tIME                                                            Chunk)
    (iTXt                                                            Chunk)
    (tEXt                                                            Chunk)
    (zTXt                                                            Chunk)))

(coalton-toplevel

  (define-struct Palette-Entry
    (Red U8)
    (Green U8)
    (Blue U8))

  (define-type Palette ;; ideally limited to 255 entries
    (Palette (Vector Palette-Entry)))


  (define-type Header
    ;; for width and height, zero is an invalid value
    (Width              4Bytes)
    (Height             4Bytes)
    (Bit-Depth          U8)
    (Colour-Type        U8)
    (Compression-Method U8)
    (Filter-Method      U8)
    (Interlace-method   U8))
  )
