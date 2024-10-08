import Vrtcal_Adapters_Wrapper_Parent
import AppLovinSDK

class VrtcalAppLovinAdaptersWrapper: NSObject, AdapterWrapperProtocol {
    
    var appLogger: Logger
    var sdkEventsLogger: Logger
    var sdk = SDK.appLovin
    var delegate: AdapterWrapperDelegate

    var maInterstitialAd: MAInterstitialAd?
    
    required init(
        appLogger: Logger,
        sdkEventsLogger: Logger,
        delegate: AdapterWrapperDelegate
    ) {
        self.appLogger = appLogger
        self.sdkEventsLogger = sdkEventsLogger
        self.delegate = delegate
    }
    
    func initializeSdk() {
        appLogger.log()
        
        // Create the initialization configuration
        let alSdkInitializationConfiguration = ALSdkInitializationConfiguration(
            sdkKey: "zX98f05BcqcbWKqKiHeqHpHOF9CFD46s7sQfrikSgw6AnroGcf22Ep1qH-IvnL4viE5rkF5qTNvBzT_EzNClPh"
        ) { (alSdkInitializationConfigurationBuilder: ALSdkInitializationConfigurationBuilder) in
            alSdkInitializationConfigurationBuilder.mediationProvider = ALMediationProviderMAX
            
            // Get all the ad units we'll be using
            let adUnitIdentifiers = AdTechConfigProvider.allCases.compactMap {
                let adTechConfig = $0.adTechConfig
                if adTechConfig.primarySdk == .appLovin {
                    return adTechConfig.adUnitId
                }
                
                if adTechConfig.secondarySdk == .appLovin {
                    return adTechConfig.secondaryAdUnitId
                }
                
                return nil
            }
            alSdkInitializationConfigurationBuilder.adUnitIdentifiers = adUnitIdentifiers
            
            appLogger.log("adUnitIdentifiers: \(adUnitIdentifiers)")
        }
        
        // Enable verbose logging
        ALSdk.shared().settings.isVerboseLoggingEnabled = true
        
        ALSdk.shared().initialize(with: alSdkInitializationConfiguration) { (configuration: ALSdkConfiguration) in
            self.appLogger.log("configuration: \(configuration)")
            
            // Start loading ads
            self.sdkEventsLogger.log("AppLovin Initialized")
        }
    }
    
    func handle(adTechConfig: AdTechConfig) {
        
        switch adTechConfig.placementType {
                
            case .banner:
                appLogger.log("AppLovin Banner - VRTMediationAdapter")
                let maAdView = MAAdView(
                    adUnitIdentifier: adTechConfig.adUnitId
                )
                maAdView.delegate = self
                delegate.adapterWrapperDidProvide(banner: maAdView)
                maAdView.loadAd()
                
            case .interstitial:
                appLogger.log("AppLovin Interstitial - VRTMediationAdapter")
                maInterstitialAd = MAInterstitialAd(
                    adUnitIdentifier: adTechConfig.adUnitId
                )
                maInterstitialAd?.delegate = self
                maInterstitialAd?.load()

            case .rewardedVideo:
                sdkEventsLogger.log("rewardedVideo not supported for AppLovin")
                
            case .showDebugView:
                ALSdk.shared().showMediationDebugger()
        }
    }
    
    func showInterstitial() -> Bool {
        if let maInterstitialAd, maInterstitialAd.isReady {
            maInterstitialAd.show()
            return true
        }
        
        return false
    }
    
    func destroyInterstitial() {
        maInterstitialAd = nil
    }
}

extension VrtcalAppLovinAdaptersWrapper: MAAdDelegate {
    
    func didLoad(_ ad: MAAd) {
        appLogger.log()
        sdkEventsLogger.log("AppLovin didLoad")
    }
    
    func didFailToLoadAd(
        forAdUnitIdentifier adUnitIdentifier: String,
        withError error: MAError
    ) {
        appLogger.log("error: \(error)")
        sdkEventsLogger.log("AppLovin didFailToLoad: \(error)")
    }
    
    func didDisplay(_ ad: MAAd) {
        appLogger.log()
        sdkEventsLogger.log("AppLovin didDisplay")
    }
    
    func didHide(_ ad: MAAd) {
        appLogger.log()
        sdkEventsLogger.log("AppLovin didHide")
    }
    
    func didClick(_ ad: MAAd) {
        appLogger.log()
        sdkEventsLogger.log("AppLovin didClick")
    }
    
    func didFail(
        toDisplay ad: MAAd,
        withError error: MAError
    ) {
        appLogger.log("error: \(error)")
        sdkEventsLogger.log("AppLovin didFailToDisplay: \(error)")
    }
}

extension VrtcalAppLovinAdaptersWrapper: MAAdViewAdDelegate {
    func didExpand(_ ad: MAAd) {
        sdkEventsLogger.log("AppLovin didExpand")
    }
    
    func didCollapse(_ ad: MAAd) {
        sdkEventsLogger.log("AppLovin didCollapse")
    }
}
