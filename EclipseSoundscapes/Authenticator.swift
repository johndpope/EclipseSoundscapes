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

//Authentication Error Codes
public enum AuthError: Error {
    
    /// No User Currently Signed In
    case noCurrentUser
}

/// Authentication Functionality for EclipseSoundscpes Users in connection with Firebase
public class Authenticator {
    
    /// Simple Wrappper for a (FIRUser?, Error?) -> Void Completion block
    typealias AuthenticatorCallback = ((User?, Error?) -> Void)
    
    /// Access to the Authenticator Object
    static var auth : Authenticator {
        return Authenticator()
    }
    
    /// Sign In with Email and Password combination
    ///
    /// - Parameters:
    ///   - email: User's email associated with their account
    ///   - password: Password to the corresponding account
    ///   - completion: optional Completion block containg the Authenticated User and possible error
    /// - Remark:
    ///     - Possible error codes:
    ///         - FIRAuthErrorCodeOperationNotAllowed - Indicates that accounts
    ///             with the identity provider represented by the credential are not enabled.
    ///             Enable them in the Auth section of the Firebase console.
    ///         - FIRAuthErrorCodeUserDisabled - Indicates the user's account is disabled.
    ///         - FIRAuthErrorCodeWrongPassword - Indicates the user attempted sign in with an
    ///             incorrect password, if credential is of the type EmailPasswordAuthCredential.
    ///         - FIRAuthErrorCodeInvalidEmail - Indicates the email address is malformed.
    func signIn(withEmail email : String, password : String, _ completion:  AuthenticatorCallback? = nil) {
        
        Auth.auth().signIn(withEmail: email, password: password, completion: { (user, error) in
            guard error == nil else {
                completion?(nil, error)
                return
            }
            
            print("User Logged In")
            completion?(user, nil)
        })
        
    }
    
    /// Sign out the Current User
    ///
    /// - Parameter completion: optional Completion block containg possible error
    /// - Remark:
    ///     - Possible error code:
    ///         -FIRAuthErrorCodeKeychainError - Indicates an error occurred when accessing the
    ///             keychain. The NSLocalizedFailureReasonErrorKey field in the NSError. userInfo
    ///             dictionary will contain more information about the error encountered.
     func signOut(_ completion:  ((Error?) -> Void)? = nil) {
        do {
            try Auth.auth().signOut()
            print("User Logged Out")
            completion?(nil)
            
        } catch { let error = error
            completion?(error)
        }
    }
    
    /// Create New Account using Email and Password Combination
    ///
    /// - Parameters:
    ///   - email: User's email associated with their account
    ///   - password: Password to the corresponding account
    ///   - completion: optional Completion block containg the Authenticated User and possible error
    /// - Remark:
    ///     - Possible error codes:
    ///         - FIRAuthErrorCodeInvalidEmail - Indicates the email address is malformed.
    ///         - FIRAuthErrorCodeEmailAlreadyInUse - Indicates the email used to attempt sign up
    ///             already exists. Call fetchProvidersForEmail to check which sign-in mechanisms the user
    ///             used, and prompt the user to sign in with one of those.
    ///         - FIRAuthErrorCodeOperationNotAllowed - Indicates that email and password accounts
    ///             are not enabled. Enable them in the Auth section of the Firebase console.
    ///         - FIRAuthErrorCodeWeakPassword - Indicates an attempt to set a password that is
    ///             considered too weak. The NSLocalizedFailureReasonErrorKey field in the NSError.userInfo
    ///             dictionary object will contain more detailed explanation that can be shown to the user.
     func createAccount(withEmail email: String, password : String, _ completion :  AuthenticatorCallback? = nil) {
        Auth.auth().createUser(withEmail: email, password: password, completion: { (user, error) in
            guard error == nil else {
                completion?(nil, error)
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
    /// - Remark:
    ///     - Possible error code:
    ///         - FIRAuthErrorCodeInvalidRecipientEmail - Indicates an invalid recipient email was
    ///             sent in the request.
    func forgotPassword(withEmail email : String, _ completion: ((Error?) -> Void)? = nil) {
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
    ///   - password: User's Current Password
    ///   - completion: optional Completion block containg possible error
    /// - Remark:
    ///     - Possible error code: 
    ///         - signIn Errors
    ///         - FIRAuthErrorCodeWeakPassword - Indicates an attempt to set a password that is
    ///             considered too weak. The NSLocalizedFailureReasonErrorKey field in the NSError.userInfo
    ///             dictionary object will contain more detailed explanation that can be shown to the user.
    func changePassword(password: String, NewPassword newPassword: String, _ completion : ((Error?) -> Void)? = nil) {
        guard let user = Auth.auth().currentUser, let email = user.email else {
            completion?(AuthError.noCurrentUser)
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
    
    /// Change User's Current Email
    ///
    /// - Parameters:
    ///   - password: User's Current Password
    ///   - newEmail: New Email
    ///   - completion: optional Completion block containg possible error
    /// - Remark:
    ///     - Possible error code:
    ///         - signIn Errors
    ///         - FIRAuthErrorCodeEmailAlreadyInUse - Indicates the email is already in use by another
    ///             account.
    ///         - FIRAuthErrorCodeInvalidEmail - Indicates the email address is malformed.
    func changeEmail(password: String, newEmail: String, _ completion : ((Error?) -> Void)? = nil) {
        guard let user = Auth.auth().currentUser, let email = user.email else {
            completion?(AuthError.noCurrentUser)
            return
        }
        
        let credential = EmailAuthProvider.credential(withEmail: email, password: password)
        
        user.reauthenticate(with: credential) { (error) in
            guard error == nil else {
                completion?(error)
                return
            }
            
            user.updateEmail(to: newEmail, completion: { (error) in
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
    /// 1. A current user must first be non-nil, else Error occurs.
    /// 2. User's email and password are used to reauthenticate the user before deletion of the account is possible.
    /// 3. Errors involed are equivalent to possible errors for Login function.
    /// 4. The deletion is performed if previous considerations pass.
    ///
    /// - Parameters:
    ///   - email: User's email
    ///   - password: User's password
    ///   - completion: optional Completion block containg possible error
    /// - Remark:
    ///     - Possible error code:
    ///         - signIn Errors
    ///         - FIRAuthErrorCodeRequiresRecentLogin - Updating email is a security sensitive
    ///             operation that requires a recent login from the user. This error indicates the user
    ///             has not signed in recently enough. To resolve, reauthenticate the user by invoking
    ///             reauthenticateWithCredential:completion: on FIRUser.
    func delete(withPassword password: String, _ completion : ((Error?) -> Void)? = nil) {
        guard let user = Auth.auth().currentUser, let email = user.email else {
            completion?(AuthError.noCurrentUser)
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
    func setDisplayName(withName name : String, _ completion : ((Error?) -> Void)? = nil) {
        guard let user = Auth.auth().currentUser else {
            completion?(AuthError.noCurrentUser)
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
            throw AuthError.noCurrentUser
        }
        
        return user.displayName
    }
    
    /// User's Profile information
    ///
    /// - Returns: Profile Information including email, photoUrl, and display name
    /// - Throws: Error is no User is currently logged in
    func getUserInforamtion()throws -> [String:Any]? {
        guard let user = Auth.auth().currentUser else {
            throw AuthError.noCurrentUser
        }
        
        var info = Dictionary<String, Any>()
        
        if let email = user.email {
            info.updateValue(email, forKey: "email")
        }
        
        if let photUrl = user.photoURL {
            info.updateValue(photUrl, forKey: "photoUrl")
        }
        
        if let displayName = user.displayName {
            info.updateValue(displayName, forKey: "displayName")
        }
        
        return info.isEmpty ? nil : info
    }
    
}
