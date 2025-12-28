import Foundation
import CoreNFC

class NFCManager: NSObject, ObservableObject {
    @Published var isScanning = false
    @Published var lastScannedTag: String?
    @Published var errorMessage: String?

    private var nfcSession: NFCNDEFReaderSession?
    private var tagSession: NFCTagReaderSession?

    // MARK: - Public Methods

    func startScanning() {
        guard NFCNDEFReaderSession.readingAvailable else {
            errorMessage = "NFC is not available on this device"
            print("NFC not available")
            return
        }

        // Reset state
        lastScannedTag = nil
        errorMessage = nil
        isScanning = true

        // Create and start NFC session
        nfcSession = NFCNDEFReaderSession(
            delegate: self,
            queue: nil,
            invalidateAfterFirstRead: true
        )
        nfcSession?.alertMessage = "Hold your iPhone near the NFC chip to toggle app blocking"
        nfcSession?.begin()
    }

    func stopScanning() {
        nfcSession?.invalidate()
        nfcSession = nil
        isScanning = false
    }

    // MARK: - Tag Identification

    private func getTagIdentifier(from tag: NFCNDEFTag) -> String {
        // Generate a unique identifier for the tag
        let timestamp = Date().timeIntervalSince1970
        return "NFC_TAG_\(Int(timestamp))"
    }
}

// MARK: - NFCNDEFReaderSessionDelegate
extension NFCManager: NFCNDEFReaderSessionDelegate {

    func readerSession(_ session: NFCNDEFReaderSession, didInvalidateWithError error: Error) {
        DispatchQueue.main.async {
            self.isScanning = false

            // Check if it was a user cancellation
            let nfcError = error as? NFCReaderError
            if nfcError?.code != .readerSessionInvalidationErrorUserCanceled {
                self.errorMessage = error.localizedDescription
                print("NFC Session invalidated with error: \(error.localizedDescription)")
            }
        }
    }

    func readerSession(_ session: NFCNDEFReaderSession, didDetectNDEFs messages: [NFCNDEFMessage]) {
        // Process NDEF messages
        DispatchQueue.main.async {
            self.isScanning = false

            // Get tag data from the first message
            if let firstMessage = messages.first,
               let firstRecord = firstMessage.records.first {
                let tagId = self.extractTagId(from: firstRecord)
                self.lastScannedTag = tagId
                print("Detected NFC tag with ID: \(tagId)")
            } else {
                // Even without a message, trigger the toggle
                self.lastScannedTag = "UNKNOWN_TAG_\(Date().timeIntervalSince1970)"
                print("Detected NFC tag without NDEF message")
            }
        }
    }

    func readerSession(_ session: NFCNDEFReaderSession, didDetect tags: [NFCNDEFTag]) {
        guard let tag = tags.first else {
            session.invalidate(errorMessage: "No tag found")
            return
        }

        // Connect to the tag
        session.connect(to: tag) { error in
            if let error = error {
                session.invalidate(errorMessage: "Connection failed: \(error.localizedDescription)")
                return
            }

            // Read NDEF message
            tag.queryNDEFStatus { status, capacity, error in
                if let error = error {
                    session.invalidate(errorMessage: "Query failed: \(error.localizedDescription)")
                    return
                }

                switch status {
                case .notSupported:
                    // Tag doesn't support NDEF, but we can still use it as a trigger
                    DispatchQueue.main.async {
                        self.lastScannedTag = "NON_NDEF_TAG_\(Date().timeIntervalSince1970)"
                        self.isScanning = false
                    }
                    session.alertMessage = "Tag detected! Toggling app blocking."
                    session.invalidate()

                case .readOnly, .readWrite:
                    // Read the NDEF message
                    tag.readNDEF { message, error in
                        DispatchQueue.main.async {
                            self.isScanning = false

                            if let message = message,
                               let record = message.records.first {
                                self.lastScannedTag = self.extractTagId(from: record)
                            } else {
                                self.lastScannedTag = "EMPTY_TAG_\(Date().timeIntervalSince1970)"
                            }
                        }
                        session.alertMessage = "Tag detected! Toggling app blocking."
                        session.invalidate()
                    }

                @unknown default:
                    session.invalidate(errorMessage: "Unknown tag status")
                }
            }
        }
    }

    // MARK: - Helper Methods

    private func extractTagId(from record: NFCNDEFPayload) -> String {
        // Try to extract a meaningful ID from the payload
        if let payloadString = String(data: record.payload, encoding: .utf8) {
            return payloadString
        }

        // Fall back to using the payload as hex
        let hexString = record.payload.map { String(format: "%02x", $0) }.joined()
        return hexString.isEmpty ? "TAG_\(Date().timeIntervalSince1970)" : hexString
    }
}
