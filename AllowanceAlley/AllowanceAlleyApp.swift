// AllowanceAlleyApp.swift
import SwiftUI
@main
struct AllowanceAlleyApp: App {
  @StateObject private var supabase = SupabaseService()
  var body: some Scene {
    WindowGroup { MainRouterView().environmentObject(supabase) }
  }
}
