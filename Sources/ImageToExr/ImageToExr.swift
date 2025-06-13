import class CoreImage.CIContext
import class CoreImage.CIImage
import struct Foundation.Data

public enum ImgToExrErr: Error {
  case invalid_image(String)
  case unimplemented(String)
}

public func data2image(_ data: Data) -> Result<CIImage, Error> {
  let oimg: CIImage? = CIImage(data: data)
  guard let img = oimg else {
    return .failure(ImgToExrErr.invalid_image("the image was nil"))
  }
  return .success(img)
}

public func img2exr(_ img: CIImage, ctx: CIContext) -> Result<Data, Error> {
  Result(catching: {
    try ctx.openEXRRepresentation(
      of: img,
      options: [:]
    )
  })
}

public struct ExrData: Sendable {
  public let ctype: String = "image/x-exr"
  public let data: Data

  public static func fromImage(_ img: CIImage, ctx: CIContext) -> Result<Self, Error> {
    let rdat: Result<Data, _> = img2exr(img, ctx: ctx)
    return rdat.map {
      let dat: Data = $0
      return Self(data: dat)
    }
  }

  public static func fromImgData(_ imgDat: Data, ctx: CIContext) -> Result<Self, Error> {
    let rimg: Result<CIImage, _> = data2image(imgDat)
    return rimg.flatMap {
      let img: CIImage = $0
      return Self.fromImage(img, ctx: ctx)
    }
  }
}
