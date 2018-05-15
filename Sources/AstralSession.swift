//
//  Astral
//  Copyright (c) 2017-2018 Julio Miguel Alorro
//  Licensed under the MIT license. See LICENSE file
//

import Foundation

/**
 Astral is used to do URLSession configuration for RequestDispatchers. It is typically a singleton that configures the URLSession
 for general http networking of RequestDispatchers. The the default implementation of defaultConfiguration uses the URLSession shared instance.
 If you want more control what the specifications of a URLSession for certain RequestDispatchers. Simply create another instance of Astral and override
 the RequestDispatcher(s)' session to use that Astral's session.
*/
public final class Astral {

    // MARK: Configuration Struct
    /**
     Astral.Configuration simply holds the URLSession to be used by RequestDispatchers that adopt that session.
    */
    public struct Configuration {

        // MARK: Static Properties
        /**
         The default Configuration.
        */
        public static var defaultConfiguration: Astral.Configuration {
            get { return Astral.Configuration._defaultConfiguration }

            set { self._defaultConfiguration = newValue }
        }

        // MARK: Stored Properties
        /**
         The URLSession managed by this Configuration
        */
        public let session: URLSession

        private static var _defaultConfiguration: Astral.Configuration = Astral.Configuration(session: URLSession.shared)

    }

    // MARK: Static Properties
    /**
     The Singleton instance of Astral that uses the default Configuration.
    */
    public static let shared: Astral = Astral()

    // MARK: Initializers
    /**
     Astral is used to do URLSession configuration for RequestDispatchers. It is typically a singleton that configures the URLSession
     for general http networking of RequestDispatchers. The the default implementation of defaultConfiguration uses the URLSession shared instance.
     If you want more control what the specifications of a URLSession for certain RequestDispatchers. Simply create another instance of Astral and override
     the RequestDispatcher(s)' session to use that Astral's session.

     - parameter configuration: The Astral.Configuration instance to be managed by this Astral instance.
    */
    public init(configuration: Astral.Configuration) {
        self.configuration = configuration
    }

    private convenience init() {
        self.init(configuration: Astral.Configuration.defaultConfiguration)
    }

    // MARK: Stored Properties
    /**
     The Configuration instance.
    */
    public var configuration: Astral.Configuration

    // MARK: Computed Properties
    /**
     The URLSession being managed by the Configuration instance.
    */
    public var session: URLSession {
        return self.configuration.session
    }

}
