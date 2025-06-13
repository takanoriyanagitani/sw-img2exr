import class AsyncAlgorithms.AsyncChannel
import class CoreImage.CIContext
import struct Foundation.Data
import struct Hummingbird.Application
import struct Hummingbird.ByteBuffer
import struct Hummingbird.HBHTTPError
import struct Hummingbird.HTTPFields
import struct Hummingbird.Request
import struct Hummingbird.Response
import class Hummingbird.Router
import struct ImageToExr.ExrData

enum ImgToExrApiErr: Error {
  case noreply(String)
}

struct ConvertRequest {
  public let imgData: Data
  public let reply: AsyncChannel<Result<ExrData, Error>>
}

func handleRequests(ctx: CIContext, reqs: AsyncChannel<ConvertRequest>) async {
  for await req in reqs {
    let imgDat: Data = req.imgData
    let reply: AsyncChannel<Result<ExrData, _>> = req.reply
    let redat: Result<ExrData, _> = ExrData.fromImgData(imgDat, ctx: ctx)
    await reply.send(redat)
    reply.finish()
  }
}

func request2data(_ req: Request, limit: Int) async -> Result<Data, Error> {
  do {
    let buf: ByteBuffer = try await req.body.collect(upTo: limit)
    return .success(Data(buffer: buf))
  } catch {
    return .failure(error)
  }
}

func imgdat2exr(
  _ imgDat: Data,
  ch: AsyncChannel<ConvertRequest>,
) async -> Result<ExrData, Error> {
  let req = ConvertRequest(imgData: imgDat, reply: AsyncChannel())
  await ch.send(req)
  for await r in req.reply {
    return r
  }
  return .failure(ImgToExrApiErr.noreply("no reply got"))
}

@main
struct ImgToExrApi {
  static func main() async throws {
    let router: Router = Router()

    let limit: Int = 1_048_576

    let reqs: AsyncChannel<ConvertRequest> = AsyncChannel()
    defer {
      reqs.finish()
    }

    Task.detached {
      let ctx: CIContext = CIContext()
      await handleRequests(ctx: ctx, reqs: reqs)
    }

    router.post("img2exr") { req, _ -> Response in
      let rdat: Result<Data, _> = await request2data(req, limit: limit)
      let odat: Data? = try? rdat.get()
      guard let dat = odat else {
        return Response(
          status: .contentTooLarge,
          headers: [:],
          body: .init(),
        )
      }

      let redat: Result<ExrData, _> = await imgdat2exr(dat, ch: reqs)
      let oedat: ExrData? = try? redat.get()
      guard let edat = oedat else {
        return Response(
          status: .badRequest,
          headers: [:],
          body: .init(),
        )
      }

      let ctyp: String = edat.ctype
      let data: Data = edat.data

      return Response(
        status: .ok,
        headers: [.contentType: ctyp],
        body: .init(byteBuffer: ByteBuffer(data: data)),
      )
    }

    let app: Application = Application(
      router: router,
      configuration: .init(
        address: .hostname("127.0.0.1", port: 61280),
      ),
    )

    try await app.runService()
  }
}
