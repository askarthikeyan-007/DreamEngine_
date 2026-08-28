exports.config = {
    //
    // ====================
    // Runner Configuration
    // ====================
    //
    runner: 'local',
    port: 4723,
    path: '/',

    autoCompileOpts: {
        autoCompile: false
    },

    //
    // ==================
    // Specify Test Files
    // ==================
    //
    specs: [
        './tests/**/*.test.js'
    ],
    exclude: [
        // 'path/to/excluded/files'
    ],

    //
    // ============
    // Capabilities
    // ============
    //
    maxInstances: 1,
    // Define configurations for Android or iOS
    capabilities: [
        // Android Configuration (Enabled by default, can be toggled using environment variables)
        {
            platformName: 'Android',
            'appium:automationName': 'UiAutomator2',
            'appium:deviceName': 'Android Emulator',
            // Absolute or relative path to your pre-built APK file
            'appium:app': process.env.APP_PATH || '../build/app/outputs/flutter-apk/app-debug.apk',
            'appium:autoGrantPermissions': true, // Automatically grant storage, location, etc.
            'appium:newCommandTimeout': 240,
            'appium:appWaitActivity': '*', // Handle splash screen and dynamic launch activity
        }
        /*
        // iOS Configuration (Uncomment and run with platform=ios environment variable)
        ,{
            platformName: 'iOS',
            'appium:automationName': 'XCUITest',
            'appium:deviceName': 'iPhone Simulator',
            'appium:platformVersion': '17.0', // Adjust to your local Xcode version
            'appium:app': process.env.APP_PATH || '../ios/build/Build/Products/Debug-iphonesimulator/DreamEngine.app',
            'appium:newCommandTimeout': 240,
        }
        */
    ],

    //
    // ===================
    // Test Configurations
    // ===================
    //
    logLevel: 'info',
    bail: 0,
    baseUrl: 'http://localhost',
    waitforTimeout: 30000,
    connectionRetryTimeout: 120000,
    connectionRetryCount: 3,

    services: [], // Set to empty to connect to the Appium server started externally in CI/CD, or add 'appium' if running locally automatically.

    framework: 'mocha',
    reporters: ['spec'],
    mochaOpts: {
        ui: 'bdd',
        timeout: 120000 // 2 minutes timeout for mobile actions
    }
};
