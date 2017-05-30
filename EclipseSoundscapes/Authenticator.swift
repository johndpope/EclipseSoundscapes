//
//  Authenticator.swift
//  EclipseSoundscapes
//
//  Created by Anonymous on 5/23/17.
//  Copyright © 2017 DevByArlindo. All rights reserved.
//

import Foundation
import FirebaseAuth
import Firebase


/// Wrapper for Error specifically for Authentication Errors
protocol AuthErrorProtocol: Error {
    
    var localizedTitle: String { get }
    var localizedDescription: String { get }
    var code: Int { get }
}


/// Authenticator Error Object 
struct AuthError: AuthErrorProtocol {
    
    var localizedTitle: String
    var localizedDescription: String
    var code: Int
    
    init(localizedTitle: String?, localizedDescription: String, code: Int) {
        self.localizedTitle = localizedTitle ?? "Error"
        self.localizedDescription = localizedDescription
        self.code = code
    }
}

enum USER: String {
    case displayName = "DisplayName"
    case photoUrl = "PhotoUrl"
    case email = "Email"
}


/// Authentication Functionality for EclipseSoundscpes
class Authenticator {
    
    
    
    /// Simple Wrappper for a (FIRUser?, Error?) -> Void Completion block
    typealias AuthenticatorCallback = ((User?, Error?) -> Void)
    
    /// Access to the Authenticator Object
    ///
    /// - Returns: Authenticator Object
    static func auth()-> Authenticator? {
        return Authenticator()
    }
    
    /// Login User In with Email and Password combination
    ///
    /// - Parameters:
    ///   - email: User's email associated with their account
    ///   - password: Password to the corresponding account
    ///   - completion: optional Completion block containg the Authenticated User and possible error
    ///     - Possible error codes:
    ///
    ///         - FIRAuthErrorCodeInvalidCredential - Indicates the supplied credential is invalid.
    ///             This could happen if it has expired or it is malformed.
    ///         - FIRAuthErrorCodeOperationNotAllowed - Indicates that accounts
    ///             with the identity provider represented by the credential are not enabled.
    ///             Enable them in the Auth section of the Firebase console.
    ///         - FIRAuthErrorCodeEmailAlreadyInUse - Indicates the email asserted by the credential
    ///             (e.g. the email in a Facebook access token) is already in use by an existing account,
    ///             that cannot be authenticated with this sign-in method. Call fetchProvidersForEmail for
    ///             this user’s email and then prompt them to sign in with any of the sign-in providers
    ///             returned. This error will only be thrown if the "One account per email address"
    ///             setting is enabled in the Firebase console, under Auth settings. Please note that the
    ///             error code raised in this specific situation may not be the same on
    ///             Web and Android.
    ///         - FIRAuthErrorCodeUserDisabled - Indicates the user's account is disabled.
    ///         - FIRAuthErrorCodeWrongPassword - Indicates the user attempted sign in with an
    ///             incorrect password, if credential is of the type EmailPasswordAuthCredential.
    ///         - FIRAuthErrorCodeInvalidEmail - Indicates the email address is malformed.
    func login(withEmail email : String, password : String, completion:  AuthenticatorCallback? = nil) {
        
        Auth.auth().signIn(withEmail: email, password: password, completion: { (user, error) in
            guard error == nil else {
                completion?(nil,error)
                return
            }
            
            print("User Logged In")
            completion?(user, nil)
        })
        
    }
    
    
    /// Logout the Current User
    ///
    /// - Parameter completion: optional Completion block containg possible error
     func logout(_ completion:  ((Error?) -> Void)? = nil) {
        do {
            try Auth.auth().signOut()
            print("User Logged Out")
            completion?(nil)
            
        }
        catch{ let error = error
            completion?(error)
        }
    }
    
    
    
    /// Create New Account using Email and Password Combination
    ///
    /// - Parameters:
    ///   - email: User's email associated with their account
    ///   - password: Password to the corresponding account
    ///   - completion: optional Completion block containg the Authenticated User and possible error
    ///
    ///     - Possible error codes:
    ///
    ///         - FIRAuthErrorCodeWeakPassword - Indicates an attempt to set a password that is
    ///         - FIRAuthErrorCodeOperationNotAllowed - Indicates the administrator disabled sign
    ///             in with the specified identity provider.
    ///         - FIRAuthErrorCodeExpiredActionCode - Indicates the OOB code is expired.
    ///         - FIRAuthErrorCodeInvalidActionCode - Indicates the OOB code is invalid.
     func createAccount(withEmail email: String, password : String, completion :  AuthenticatorCallback? = nil) {
        Auth.auth().createUser(withEmail: email, password: password, completion: { (user, error) in
            guard error == nil else {
                completion?(nil,error)
                return
            }
            print("User Created and Logged In")
            completion?(user, nil)
        })
    }
    
    
    
    /// Forgot Password for User
    ///
    /// - Parameters:
    ///   - email: User's email
    ///   - completionHandler: optional Completion block containg possible error
    ///     
    ///     - Possible error code:
    ///         
    ///         -FIRAuthErrorCodeKeychainError - Indicates an error occurred when accessing the
    ///             keychain. The NSLocalizedFailureReasonErrorKey field in the NSError. userInfo
    ///             dictionary will contain more information about the error encountered.
    func forgotPassword(withEmail email : String, completion: ((Error?) -> Void)? = nil){
        Auth.auth().sendPasswordReset(withEmail: email, completion: { (error) in
            guard error == nil else {
                completion?(error)
                return
            }
                print("Email for password sent")
                completion?(nil)
            
        })
    }
    
    
    
    /// Change User's Current Password
    ///
    /// - Parameters:
    ///   - password: Password
    ///   - completion: optional Completion block containg possible error
    func changePassword(CurrentPassword password: String, NewPassword newPassword: String, completion : ((Error?) -> Void)? = nil) {
        guard let user = Auth.auth().currentUser, let email = user.email else {
            let error = AuthError(localizedTitle: "No User Signed In", localizedDescription: "There is no User currently signed into Eclipse Soundscapes", code: 1)
            completion?(error)
            return
        }
    
        let credential = EmailAuthProvider.credential(withEmail: email, password: password)
        
        user.reauthenticate(with: credential) { (error) in
            guard error == nil else {
                completion?(error)
                return
            }
            user.updatePassword(to: newPassword, completion: { (error) in
                guard error == nil else {
                    completion?(error)
                    return
                }
                completion?(nil)
            })
        }
    }
    
    
    
    
    
    
    /// Delete User from Firebase Auth System & Eclipse Soundscapes
    ///
    /// - Parameters:
    ///   - email: User's email
    ///   - password: User's password
    ///   - completion: optional Completion block containg possible error
    ///     
    ///     - Possible error code:
    ///         - FIRAuthErrorCodeRequiresRecentLogin - Updating email is a security sensitive
    ///             operation that requires a recent login from the user. This error indicates the user
    ///             has not signed in recently enough. To resolve, reauthenticate the user by invoking
    ///             reauthenticateWithCredential:completion: on FIRUser.
    /// - Usage:
    ///     - A current user must first be non-nil, else Error occurs
    ///     - User's email and password are used to reauthenticate the user before deletion of the account is possible
    ///         - Errors involed are equivalent to possible errors for Login function
    ///     - The deletion is performed if previous considerations pass
    func deleteAccount(withPassword password: String, completion : ((Error?) -> Void)? = nil) {
        guard let user = Auth.auth().currentUser, let email = user.email else {
            let error = AuthError(localizedTitle: "No User Signed In", localizedDescription: "There is no User currently signed into Eclipse Soundscapes", code: 1)
            completion?(error)
            return
        }
        
        let credential = EmailAuthProvider.credential(withEmail: email, password: password)
        
        user.reauthenticate(with: credential) { (error) in
            guard error == nil else {
                completion?(error)
                return
            }
            
            user.delete(completion: { (error) in
                guard error == nil else {
                    completion?(error)
                    return
                }
                
                completion?(nil)
            })
        }
    }
    
    
    /// Set/Change User's Display Name
    ///
    /// - Parameters:
    ///   - name: New Display Name
    ///   - completion: optional Completion block containg possible error
    func setDisplayName(withName name : String, completion : ((Error?) -> Void)? = nil) {
        guard let user = Auth.auth().currentUser else {
            let error = AuthError(localizedTitle: "No User Signed In", localizedDescription: "There is no User currently signed into Eclipse Soundscapes", code: 1)
            completion?(error)
            return
        }
        
        let changeReq = user.createProfileChangeRequest()
        
        changeReq.displayName = name
        changeReq.commitChanges { (error) in
            guard error == nil else {
                completion?(error)
                return
            }
            
            print("Display name changed!")
            completion?(nil)
        }
    }
    
    
    /// Return User's Display Name
    ///
    /// - Returns: User's Display name (optional)
    /// - Throws: Error if no User currently signed in
    func getDisplayName() throws -> String? {
        guard let user = Auth.auth().currentUser else {
            let error = AuthError(localizedTitle: "No User Signed In", localizedDescription: "There is no User currently signed into Eclipse Soundscapes", code: 1)
            throw error
        }
        
        return user.displayName
    }
    
    func getUserInforamtion()throws -> [String:Any]? {
        guard let user = Auth.auth().currentUser else {
            let error = AuthError(localizedTitle: "No User Signed In", localizedDescription: "There is no User currently signed into Eclipse Soundscapes", code: 1)
            throw error
        }
        
        var info = Dictionary<String, Any>()
        
        if let email = user.email {
            info.updateValue(email, forKey: USER.email.rawValue)
        }
        
        if let photUrl = user.photoURL {
            info.updateValue(photUrl, forKey: USER.photoUrl.rawValue)
        }
        
        if let displayName = user.displayName {
            info.updateValue(displayName, forKey: USER.displayName.rawValue)
        }
        
        return info.count == 0 ? nil : info
    }
    
}
