import Foundation
import Supabase

// MARK: - Centralized config loader
enum AppConfig {
    /// SUPABASE_URL from Info.plist (or env), parsed as URL
    static var url: URL {
        // 1) Info.plist (the recommended way)
        if let s = Bundle.main.object(forInfoDictionaryKey: "SUPABASE_URL") as? String,
           let u = URL(string: s.trimmingCharacters(in: .whitespacesAndNewlines)),
           u.scheme != nil {
            return u
        }
        // 2) Process env (nice for CLI / tests)
        if let s = ProcessInfo.processInfo.environment["SUPABASE_URL"],
           let u = URL(string: s.trimmingCharacters(in: .whitespacesAndNewlines)),
           u.scheme != nil {
            return u
        }
        fatalError("Missing SUPABASE_URL (check Info.plist or your environment)")
    }

    /// SUPABASE_ANON_KEY from Info.plist (or env)
    static var anonKey: String {
        if let s = Bundle.main.object(forInfoDictionaryKey: "SUPABASE_ANON_KEY") as? String,
           !s.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            return s
        }
        if let s = ProcessInfo.processInfo.environment["SUPABASE_ANON_KEY"],
           !s.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            return s
        }
        fatalError("Missing SUPABASE_ANON_KEY (check Info.plist or your environment)")
    }
}

// MARK: - Supabase Manager
final class SupabaseManager {
    static let shared = SupabaseManager()

    let client: SupabaseClient

    private init() {
        // Gather and validate config once
        let url = AppConfig.url
        let key = AppConfig.anonKey

        // ---------- DEBUG: dump config sources (sanitized) ----------
        #if DEBUG
        SupabaseManager.debugDumpConfig(plistURL: Bundle.main.object(forInfoDictionaryKey: "SUPABASE_URL"),
                                        plistKey: Bundle.main.object(forInfoDictionaryKey: "SUPABASE_ANON_KEY"),
                                        envURL: ProcessInfo.processInfo.environment["SUPABASE_URL"],
                                        envKey: ProcessInfo.processInfo.environment["SUPABASE_ANON_KEY"])
        print("🔧 SupabaseManager: initializing client")
        print("   • Endpoint (absolute): \(url.absoluteString)")
        print("   • Host               : \(url.host ?? "<nil>")")
        print("   • Scheme             : \(url.scheme ?? "<nil>")")
        print("   • Key length         : \(key.count) chars")
        print("   • Key prefix         : \(String(key.prefix(8)))…")
        #endif

        // If you want extra headers or logging, build options here.
        // NOTE: Don't try to mutate internal "global headers" later; define in options.
        let options = SupabaseClientOptions(
            // headers: ["X-Client": "AllowanceAlley"],   // ← optional
            // logger: SomeLogger()                        // ← optional
            // auth: .init(autoRefreshToken: true)         // ← optional
        )

        // Initialize the official client
        client = SupabaseClient(supabaseURL: url, supabaseKey: key, options: options)

        #if DEBUG
        print("✅ SupabaseManager: client initialized")
        #endif
    }
}

// MARK: - Debug helpers
private extension SupabaseManager {
    /// Print what we saw in Info.plist and the environment (sanitized).
    static func debugDumpConfig(plistURL: Any?, plistKey: Any?, envURL: String?, envKey: String?) {
        func scrub(_ s: String?) -> String { s.map { String($0.prefix(8)) + "…" } ?? "<nil>" }
        func scrubURL(_ s: String?) -> String {
            guard let s, let u = URL(string: s) else { return "<nil>" }
            return "\(u.scheme ?? "?")://\(u.host ?? "?")"
        }

        print("────────────────────────────────────────")
        print("🔎 [Config] SUPABASE_URL  (plist raw): \(String(describing: plistURL))")
        print("🔎 [Config] SUPABASE_URL  (plist as URL, sanitized): \(scrubURL(plistURL as? String))")
        print("🔎 [Config] SUPABASE_URL  (env  raw): \(envURL ?? "<nil>")")
        print("🔎 [Config] SUPABASE_URL  (env  as URL, sanitized): \(scrubURL(envURL))")
        print("🔎 [Config] SUPABASE_ANON_KEY (plist raw prefix): \(scrub(plistKey as? String))")
        print("🔎 [Config] SUPABASE_ANON_KEY (env  raw prefix): \(scrub(envKey))")
        print("────────────────────────────────────────")
    }
}
