//
//  BeautifyFilter.swift
//  GPUImage
//
//  Created by zhujianxin04 on 2025/4/22.
//
public class Beautify: BasicOperation {
    public var smoothDegree: Float = 0.5 { didSet { uniformSettings["smoothDegree"] = smoothDegree } }
    public var brightness: Float = 0.5 { didSet { uniformSettings["brightness"] = brightness } }

    public init() {
        super.init(fragmentFunctionName: "beautifyFragment", numberOfInputs: 2)

        ({ smoothDegree = 0.5 })()
        ({ brightness = 0.5 })()
    }
}

