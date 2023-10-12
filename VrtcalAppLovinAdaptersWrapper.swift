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
        ALSdk.shared()!.mediationProvider = "max"
        ALSdk.shared()!.userIdentifier = "USER_ID"
        ALSdk.shared()!.settings.isVerboseLoggingEnabled = true
        
        ALSdk.shared()!.initializeSdk { (configuration: ALSdkConfiguration) in
            // Start loading ads
            self.sdkEventsLogger.log("AppLovin Initialized")
            if self.delegate.isSimulator {
                self.sdkEventsLogger.log("Note that AppLovin-As-Primary will not work on simulator")
            }
        }
    }
    
    func handle(vrtcalAsSecondaryConfig: VrtcalAsSecondaryConfig) {
        
        switch vrtcalAsSecondaryConfig.placementType {
                
            case .banner:
                appLogger.log("AppLovin Banner - VRTMPBannerCustomEvent")
                let maAdView = MAAdView(
                    adUnitIdentifier: vrtcalAsSecondaryConfig.adUnitId
                )
                maAdView.delegate = self
                delegate.provide(banner: maAdView)
                maAdView.loadAd()
                
            case .interstitial:
                appLogger.log("AppLovin Interstitial - VRTMPInterstitialCustomEvent")
                maInterstitialAd = MAInterstitialAd(
                    adUnitIdentifier: vrtcalAsSecondaryConfig.adUnitId
                )
                maInterstitialAd?.delegate = self
                maInterstitialAd?.load()

            case .rewardedVideo:
                sdkEventsLogger.log("rewardedVideo not supported for AppLovin")
                
            case .showDebugView:
                ALSdk.shared()!.showMediationDebugger()
        }
    }
    
    func showInterstitial() -> Bool {
        if let maInterstitialAd {
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
        sdkEventsLogger.log("AppLovin didLoad")
    }
    
    func didFailToLoadAd(
        forAdUnitIdentifier adUnitIdentifier: String,
        withError error: MAError
    ) {
        sdkEventsLogger.log("AppLovin didFailToLoad: \(error)")
    }
    
    func didDisplay(_ ad: MAAd) {
        sdkEventsLogger.log("AppLovin didDisplay")
    }
    
    func didHide(_ ad: MAAd) {
        sdkEventsLogger.log("AppLovin didHide")
    }
    
    func didClick(_ ad: MAAd) {
        sdkEventsLogger.log("AppLovin didClick")
    }
    
    func didFail(
        toDisplay ad: MAAd,
        withError error: MAError
    ) {
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
