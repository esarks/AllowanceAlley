// SupabaseService.swift
import Foundation
@MainActor
final class SupabaseService: ObservableObject {
  @Published var isSignedIn = true
  func session() async throws -> String? { isSignedIn ? "ok" : nil }
}
