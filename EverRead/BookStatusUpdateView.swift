//
//  BookStatusUpdateView.swift
//  EverRead
//
//  Created by Worawalan Chatlatanagulchai on 9/5/2568 BE.
//

import Foundation
import SwiftUI


struct BookStatusUpdateView: View {
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var session: UserSession

    let book: Book // Google API Book model (passed in)
    let initialStatus: BookReadingStatus? // Status when the sheet was opened
    let initialCurrentPage: Int?      // Current page when the sheet was opened
    
    @State private var selectedStatus: BookReadingStatus
    @State private var currentPageInput: String = ""
    
    @State private var isLoading: Bool = false
    @State private var alertMessage: String? = nil
    @State private var showAlert: Bool = false
    
    var onUpdateComplete: (() -> Void)?

    init(book: Book, currentStatus: BookReadingStatus, currentPage: Int?, onUpdateComplete: (() -> Void)? = nil) {
        self.book = book
        self.initialStatus = currentStatus
        self.initialCurrentPage = currentPage
        self._selectedStatus = State(initialValue: currentStatus)
        
        // Initialize currentPageInput based on current/initial state
        if let page = currentPage, page >= 0 { // Allow 0
            self._currentPageInput = State(initialValue: "\(page)")
        } else if currentStatus == .finished, let totalPages = book.pageCount, totalPages > 0 {
            // If book is finished and has page count, default to total pages
            self._currentPageInput = State(initialValue: "\(totalPages)")
        } else {
            // Default for want to read, or new currently reading without a page yet
            self._currentPageInput = State(initialValue: "0")
        }
        self.onUpdateComplete = onUpdateComplete
    }

    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Update: \(book.title)")) {
                    Picker("Reading Status", selection: $selectedStatus) {
                        ForEach(BookReadingStatus.allCases) { status in
                            Text(status.displayName).tag(status)
                        }
                    }
                    .onChange(of: selectedStatus) { newStatus in
                        // Auto-adjust current page input based on status change
                        if newStatus == .finished, let totalPages = book.pageCount, totalPages > 0 {
                            currentPageInput = "\(totalPages)"
                        } else if newStatus == .wantToRead {
                            currentPageInput = "0"
                        }
                        // For 'currently reading', user input is preserved or can be cleared if desired
                    }

                    // Show current page input only if relevant for the selected status
                    if selectedStatus == .currentlyReading || (selectedStatus == .finished && book.pageCount == nil) {
                        VStack(alignment: .leading) {
                            Text(selectedStatus == .finished ? "Pages Read (if total unknown)" : "Current Page:")
                            TextField("Enter page number", text: $currentPageInput)
                                .keyboardType(.numberPad)
                            
                            if let pageCount = book.pageCount, pageCount > 0 {
                                Text("Total Pages: \(pageCount)")
                                    .font(.caption).foregroundColor(.gray)
                            }
                        }
                    }
                }

                Section {
                    Button(action: handleSaveProgress) {
                        HStack {
                            Spacer()
                            if isLoading { ProgressView().tint(.white) } else { Text("Save Changes") }
                            Spacer()
                        }
                    }
                    .disabled(isLoading)
                    .buttonStyle(PrimaryButtonStyle()) // Ensure PrimaryButtonStyle is defined
                }
            }
            .navigationTitle("Update Progress")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) { Button("Cancel") { dismiss() } }
            }
            .alert("Update Status", isPresented: $showAlert, presenting: alertMessage) { _ in
                Button("OK") {
                    if alertMessage == "Progress updated successfully!" { // Only dismiss on success
                        dismiss()
                    }
                }
            } message: { messageText in Text(messageText) }
        }
    }

    private func handleSaveProgress() {
         isLoading = true
         alertMessage = nil
         
         let targetStatus = selectedStatus
         var userEnteredCurrentPage: Int? = nil

         // Validate and parse user's page input
         if !currentPageInput.isEmpty {
             guard let page = Int(currentPageInput), page >= 0 else {
                 finalizeUpdate(success: false, message: "Invalid page number. Please enter a non-negative number.")
                 return
             }
             userEnteredCurrentPage = page
         }

         // Further validation against total page count
         if let totalPages = book.pageCount, totalPages > 0, let current = userEnteredCurrentPage, current > totalPages {
             finalizeUpdate(success: false, message: "Current page (\(current)) cannot exceed total pages (\(totalPages)).")
             return
         }
         
         Task {
             do {
                 guard let token = session.token else { throw BookAPIService.APIError.noToken }

                 var statusChanged = (targetStatus != initialStatus)
                 var pageEffectivelyChanged = false

                 // 1. Update Overall Status - This call is crucial to ensure the book exists on the shelf.
                 //    The backend /status endpoint will set a default current_page.
                 //    We call this if status changed OR if it's the first time setting a status other than a default 'wantToRead'
                 //    (e.g. initialStatus was a default from a failed fetch and user now sets a real status).
                 var backendResponseAfterStatusUpdate: UserBookProgressResponse? = nil
                 if statusChanged || (initialStatus == .wantToRead && targetStatus != .wantToRead && userEnteredCurrentPage != 0 || !statusChanged && !pageEffectivelyChanged && initialStatus == .wantToRead) {
                     print("Calling updateBookOverallStatus for \(book.id) to status: \(targetStatus.rawValue)")
                     backendResponseAfterStatusUpdate = try await BookAPIService.shared.updateBookOverallStatus(
                         book: book,
                         newStatus: targetStatus,
                         userToken: token
                     )
                     print("updateBookOverallStatus successful.")
                 }

                 // 2. Update Current Page if necessary
                 if targetStatus == .currentlyReading {
                     if let pageToSet = userEnteredCurrentPage {
                         // Check if this page is different from what the status update might have set,
                         // or different from the initial page if status didn't change but page did.
                         let pageAfterStatusUpdate = backendResponseAfterStatusUpdate?.current_page ?? initialCurrentPage ?? 0
                         if pageToSet != pageAfterStatusUpdate || (targetStatus == initialStatus && pageToSet != initialCurrentPage) {
                             print("Calling updateBookCurrentPage for \(book.id) to page: \(pageToSet)")
                             _ = try await BookAPIService.shared.updateBookCurrentPage(
                                 apiId: book.id,
                                 newPage: pageToSet,
                                 userToken: token
                             )
                             pageEffectivelyChanged = true
                             print("updateBookCurrentPage successful.")
                         }
                     }
                 } else if targetStatus == .finished && book.pageCount == nil { // Finished, but no total pages known, user might have entered pages read
                      if let pageToSet = userEnteredCurrentPage {
                         let pageAfterStatusUpdate = backendResponseAfterStatusUpdate?.current_page ?? initialCurrentPage ?? 0
                         if pageToSet != pageAfterStatusUpdate {
                              print("Calling updateBookCurrentPage for FINISHED (no total) \(book.id) to page: \(pageToSet)")
                             _ = try await BookAPIService.shared.updateBookCurrentPage(
                                 apiId: book.id,
                                 newPage: pageToSet,
                                 userToken: token
                             )
                             pageEffectivelyChanged = true
                             print("updateBookCurrentPage for FINISHED (no total) successful.")
                         }
                      }
                 }
                 
                 // If neither status nor page effectively changed from initial state,
                 // but user hit save, still show "successful" as it's idempotent.
                 // The more critical part is ensuring the API calls are made correctly.
                 if !statusChanged && !pageEffectivelyChanged && targetStatus == initialStatus && userEnteredCurrentPage == initialCurrentPage {
                     print(statusChanged, targetStatus, pageEffectivelyChanged, initialStatus, book)
                      print("No actual change in status or page from initial state.")
                 }

                 finalizeUpdate(success: true, message: "Progress updated successfully!")
                 onUpdateComplete?()

             } catch {
                 let errorMessage = (error as? BookAPIService.APIError)?.localizedDescription ?? "An unexpected error occurred: \(error.localizedDescription)"
                 finalizeUpdate(success: false, message: errorMessage)
                 print("Error saving progress: \(error)")
             }
         }
     }
    
    private func finalizeUpdate(success: Bool, message: String) {
        isLoading = false
        alertMessage = message
        showAlert = true
    }
}


