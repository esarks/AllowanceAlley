//
//  SupabaseManager.swift
//  AllowanceAlley
//

import Foundation
import Supabase

// MARK: - AppConfig

enum AppConfig {
    enum Source: String { case infoPlist = "Info.plist", env = "Environment" }

    private static func value(for key: String) -> (value: String?, source: Source?) {
        if let v = Bundle.main.object(forInfoDictionaryKey: key) as? String, v.isEmpty == false {
            return (v, .infoPlist)
        }
        if let v = ProcessInfo.processInfo.environment[key], v.isEmpty == false {
            return (v, .env)
        }
        return (nil, nil)
    }

    private static func normalizeURLString(_ raw: String) -> String {
        var s = raw.trimmingCharacters(in: .whitespacesAndNewlines)
        if !s.lowercased().hasPrefix("http://") && !s.lowercased().hasPrefix("https://") {
            // Common mistake: missing scheme
            s = "https://" + s
        }
        return s
    }

    static var url: URL {
        let (rawValue, src) = value(for: "SUPABASE_URL")
        #if DEBUG
        print("🔎 AppConfig: reading SUPABASE_URL …")
        print("   • Bundle path: \(Bundle.main.bundlePath)")
        if let src { print("   • Found in: \(src.rawValue)") } else { print("   • Not found in Info.plist or Environment") }
        #endif

        guard let raw = rawValue else {
            fatalError("Missing SUPABASE_URL (add it to Info.plist or your scheme’s environment variables).")
        }

        let normalized = normalizeURLString(raw)
        guard let url = URL(string: normalized), let host = URL(string: normalized)?.host, !host.isEmpty else {
            fatalError("SUPABASE_URL is invalid: “\(raw)”. After normalization “\(normalized)”. It must include a valid host.")
        }

        #if DEBUG
        print("   • SUPABASE_URL resolved to: \(url.absoluteString)")
        print("   • Host: \(host)")
        #endif
        return url
    }

    static var anonKey: String {
        let (val, src) = value(for: "SUPABASE_ANON_KEY")
        #if DEBUG
        print("🔎 AppConfig: reading SUPABASE_ANON_KEY …")
        if let src { print("   • Found in: \(src.rawValue)") } else { print("   • Not found in Info.plist or Environment") }
        #endif

        guard let key = val?.trimmingCharacters(in: .whitespacesAndNewlines), !key.isEmpty else {
            fatalError("Missing SUPABASE_ANON_KEY (add it to Info.plist or your scheme’s environment variables).")
        }

        #if DEBUG
        let tail = String(key.suffix(8))
        print("   • Key length: \(key.count) (showing last 8): …\(tail)")
        #endif

        return key
    }
}

// MARK: - SupabaseManager

final class SupabaseManager {
    static let shared = SupabaseManager()

    let client: SupabaseClient

    private init() {
        // Gather and validate config
        let url = AppConfig.url
        let key = AppConfig.anonKey

        #if DEBUG
        print("🚀 SupabaseManager: initializing client")
        print("   • Endpoint: \(url.absoluteString)")
        print("   • Default REST base: \(url.appendingPathComponent("/rest/v1").absoluteString)")
        print("   • Auth base: \(url.appendingPathComponent("/auth/v1").absoluteString)")
        #endif

        // You can tweak options here if you want extra headers or logging
        var options = SupabaseClientOptions()
        // Example: add a simple header to prove headers are being merged
        options.global.headers = ["X-Client": "AllowanceAlley"]

        // Initialize
        client = SupabaseClient(supabaseURL: url, supabaseKey: key, options: options)

        #if DEBUG
        // Sanity: print the computed default storage key logic inputs
        print("✅ SupabaseManager: client initialized")
        #endif
    }

    // MARK: - Quick debug helpers

    /// Call this once on app launch to print config status in DEBUG builds.
    func debugDumpConfig() {
        #if DEBUG
        print("🧾 Supabase Debug Dump")
        print("   • URL: \(AppConfig.url.absoluteString)")
        let key = AppConfig.anonKey
        print("   • Key suffix: …\(key.suffix(8))")
        #endif
    }

    /// Lightweight network probe to ensure your URL/key combination is sane.
    /// This performs a HEAD request to `<url>/rest/v1/` which should 200/301/404 but confirm reachability.
    func probeReachability(completion: @escaping (Result<(status: Int, finalURL: URL?), Error>) -> Void) {
        let probeURL = AppConfig.url.appendingPathComponent("rest/v1/")
        var req = URLRequest(url: probeURL)
        req.httpMethod = "HEAD"
        // Include auth headers to mimic real calls
        req.addValue("Bearer \(AppConfig.anonKey)", forHTTPHeaderField: "Authorization")
        req.addValue(AppConfig.anonKey, forHTTPHeaderField: "apikey")

        let task = URLSession.shared.dataTask(with: req) { _, resp, err in
            if let err = err { return completion(.failure(err)) }
            let status = (resp as? HTTPURLResponse)?.statusCode ?? -1
            completion(.success((status, resp?.url)))
        }
        task.resume()

        #if DEBUG
        print("🌐 Probe: \(req.httpMethod ?? "HEAD") \(probeURL.absoluteString)")
        #endif
    }
}
