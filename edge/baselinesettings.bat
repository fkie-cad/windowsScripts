:: @echo off

set hkx=HKLM
set MSEdgePoliciesPath=Software\Policies\Microsoft\Edge

rem intentionally left out:
rem "BlockThirdPartyCookies"  => because you might need them in certain profiles.

rem https://learn.microsoft.com/en-us/deployedge/microsoft-edge-policies#available-policies

rem https://learn.microsoft.com/en-us/deployedge/microsoft-edge-security-browse-safer

rem There are still things missing.


rem https://learn.microsoft.com/en-us/deployedge/microsoft-edge-policies#textpredictionenabled
rem Text prediction enabled by default.
rem The Microsoft Turing service uses natural language processing to generate predictions [...]
rem No, thanks!
reg add "%hkx%\%MSEdgePoliciesPath%"  /v "TextPredictionEnabled" /t REG_DWORD /d "0" /f

rem https://learn.microsoft.com/en-us/deployedge/microsoft-edge-policies#edge3pserptelemetryenabled
rem captures the searches user does on third party search providers without identifying the person 
rem or the device and captures only if the user has consented to this collection of data.
reg add "%hkx%\%MSEdgePoliciesPath%"  /v "Edge3PSerpTelemetryEnabled" /t REG_DWORD /d "0" /f

rem Msdn: https://learn.microsoft.com/en-us/deployedge/microsoft-edge-policies#browsercodeintegritysetting
rem Disabled (0) = Do not enable code integrity guard in the browser process.
rem Audit (1) = Enable code integrity guard audit mode in the browser process.
rem Enabled (2) = Enable code integrity guard enforcement in the browser process.
reg add "%hkx%\%MSEdgePoliciesPath%"  /v "BrowserCodeIntegritySetting" /t REG_DWORD /d "2" /f



rem "we will personalize your top web sites based on your  browsing history/activities."
reg add "%hkx%\%MSEdgePoliciesPath%" /v "NewTabPageHideDefaultTopSites" /t REG_DWORD /d 1 /f

rem Page Layout / 1 - DisableImageOfTheDay / 2 -  DisableCustomImage / 3 - DisableAll
reg add "%hkx%\%MSEdgePoliciesPath%" /v "NewTabPageAllowedBackgroundTypes" /t REG_DWORD /d "3" /f

rem 1 - Allow Microsoft News content on the new tab page
reg add "%hkx%\%MSEdgePoliciesPath%" /v "NewTabPageContentEnabled" /t REG_DWORD /d "0" /f

rem 1 - Preload the new tab page for a faster experience
reg add "%hkx%\%MSEdgePoliciesPath%" /v "NewTabPagePrerenderEnabled" /t REG_DWORD /d "0" /f

rem 1 - Allow quick links on the new tab page
reg add "%hkx%\%MSEdgePoliciesPath%" /v "NewTabPageQuickLinksEnabled" /t REG_DWORD /d "0" /f

rem Search on new tabs uses search box or address bar / redirect - address bar / bing - search box
reg add "%hkx%\%MSEdgePoliciesPath%" /v "NewTabPageSearchBox" /t REG_SZ /d "redirect" /f

rem By default, the App Launcher is shown every time a user opens a new tab page.
reg add "%hkx%\%MSEdgePoliciesPath%" /v "NewTabPageAppLauncherEnabled" /t REG_DWORD /d 0 /f

rem Disable Bing chat entry-points on Microsoft Edge Enterprise new tab page
reg add "%hkx%\%MSEdgePoliciesPath%" /v "NewTabPageBingChatEnabled" /t REG_DWORD /d 0 /f

rem Hide the company logo on the Microsoft Edge new tab page
reg add "%hkx%\%MSEdgePoliciesPath%" /v "NewTabPageCompanyLogoEnabled" /t REG_DWORD /d 0 /f



rem Discover feature In Microsoft Edge (obsolete), but the button is still there...
reg add "%hkx%\%MSEdgePoliciesPath%" /v "EdgeDiscoverEnabled" /t REG_DWORD /d "0" /f

rem Block tracking of users web-browsing activity. 3=strict.
reg add "%hkx%\%MSEdgePoliciesPath%" /v "TrackingPrevention" /t REG_DWORD /d "3" /f 

rem Enables Windows to index Microsoft Edge browsing data stored locally on the user's device 
rem and allows users to find and launch previously stored browsing data directly from Windows 
rem features such as the search box on the taskbar in Windows. 
reg add "%hkx%\%MSEdgePoliciesPath%" /v "LocalBrowserDataShareEnabled" /t REG_DWORD /d "0" /f

rem let Edge make screenshot from your sites.
reg add "%hkx%\%MSEdgePoliciesPath%" /v "ShowHistoryThumbnails" /t REG_DWORD /d "0" /f

rem 1 - Allow users to access the games menu
reg add "%hkx%\%MSEdgePoliciesPath%" /v "AllowGamesMenu" /t REG_DWORD /d "0" /f

rem 1 - Enables CryptoWallet feature
reg add "%hkx%\%MSEdgePoliciesPath%" /v "CryptoWalletEnabled" /t REG_DWORD /d "0" /f

rem Enhance the security state in Microsoft Edge / 0 - Standard mode / 1 - Balanced mode / 2 - Strict mode
rem https://learn.microsoft.com/en-us/deployedge/microsoft-edge-security-browse-safer 
reg add "%hkx%\%MSEdgePoliciesPath%" /v "EnhanceSecurityMode" /t REG_DWORD /d "2" /f

rem 1 - AllowJavaScriptJit / 2 - BlockJavaScriptJit (Do not allow any site to run JavaScript JIT)
reg add "%hkx%\%MSEdgePoliciesPath%" /v "DefaultJavaScriptJitSetting" /t REG_DWORD /d "2" /f

rem 1 - Allow users to open files using the DirectInvoke protocol
reg add "%hkx%\%MSEdgePoliciesPath%" /v "DirectInvokeEnabled" /t REG_DWORD /d "0" /f

rem 1 - DNS interception checks enabled
reg add "%hkx%\%MSEdgePoliciesPath%" /v "DNSInterceptionChecksEnabled" /t REG_DWORD /d "0" /f

rem 1 - Drop lets users send messages or files to themselves
reg add "%hkx%\%MSEdgePoliciesPath%" /v "EdgeEDropEnabled" /t REG_DWORD /d "0" /f

rem 1 - Microsoft Edge can automatically enhance images to show you sharper images with better color, lighting, and contrast
reg add "%hkx%\%MSEdgePoliciesPath%" /v "EdgeEnhanceImagesEnabled" /t REG_DWORD /d "0" /f

rem 1 - Allows the Microsoft Edge browser to enable Follow service and apply it to users
reg add "%hkx%\%MSEdgePoliciesPath%" /v "EdgeFollowEnabled" /t REG_DWORD /d "0" /f

rem 1 - If you enable this policy, users will be able to access the Microsoft Edge Workspaces feature
reg add "%hkx%\%MSEdgePoliciesPath%" /v "EdgeWorkspacesEnabled" /t REG_DWORD /d "0" /f

rem 1 - Allow Google Cast to connect to Cast devices on all IP addresses (Multicast), Edge trying to connect to 239.255.255.250 via UDP port 1900
reg add "%hkx%\%MSEdgePoliciesPath%" /v "EnableMediaRouter" /t REG_DWORD /d "0" /f

rem The Experimentation and Configuration Service is used to deploy Experimentation and Configuration payloads to the client / 0 - RestrictedMode / 1 - ConfigurationsOnlyMode / 2 - FullMode
reg add "%hkx%\%MSEdgePoliciesPath%" /v "ExperimentationAndConfigurationServiceControl" /t REG_DWORD /d "0" /f

rem 1 - Allows Microsoft Edge to prompt the user to switch to the appropriate profile when Microsoft Edge detects that a link is a personal or work link
reg add "%hkx%\%MSEdgePoliciesPath%" /v "GuidedSwitchEnabled" /t REG_DWORD /d "0" /f

rem 1 - Hide restore pages dialog after browser crash
:: reg add "%hkx%\%MSEdgePoliciesPath%" /v "HideRestoreDialogEnabled" /t REG_DWORD /d "1" /f

rem 1 - Show Hubs Sidebar
reg add "%hkx%\%MSEdgePoliciesPath%" /v "HubsSidebarEnabled" /t REG_DWORD /d "0" /f

rem 1 - Enable Grammar Tools feature within Immersive Reader
reg add "%hkx%\%MSEdgePoliciesPath%" /v "ImmersiveReaderGrammarToolsEnabled" /t REG_DWORD /d "0" /f

rem 1 - Enable Picture Dictionary feature within Immersive Reader
reg add "%hkx%\%MSEdgePoliciesPath%" /v "ImmersiveReaderPictureDictionaryEnabled" /t REG_DWORD /d "0" /f

rem 1 - Allow sites to be reloaded in Internet Explorer mode (IE mode)
reg add "%hkx%\%MSEdgePoliciesPath%" /v "InternetExplorerIntegrationReloadInIEModeAllowed" /t REG_DWORD /d "0" /f

rem 1 - Shows content promoting the Microsoft Edge Insider channels on the About Microsoft Edge settings page
reg add "%hkx%\%MSEdgePoliciesPath%" /v "MicrosoftEdgeInsiderPromotionEnabled" /t REG_DWORD /d "0" /f

rem 1 - Mouse Gesture Enabled
reg add "%hkx%\%MSEdgePoliciesPath%" /v "MouseGestureEnabled" /t REG_DWORD /d "0" /f

rem 1 - Microsoft Edge built-in PDF reader powered by Adobe Acrobat enabled
reg add "%hkx%\%MSEdgePoliciesPath%" /v "NewPDFReaderEnabled" /t REG_DWORD /d "0" /f

rem - Allow QUIC protocol
rem https://learn.microsoft.com/en-us/deployedge/microsoft-edge-policies#quicallowed
reg add "%hkx%\%MSEdgePoliciesPath%" /v "QuicAllowed" /t REG_DWORD /d "0" /f

rem 1 - Enable Read Aloud feature in Microsoft Edge
reg add "%hkx%\%MSEdgePoliciesPath%" /v "ReadAloudEnabled" /t REG_DWORD /d "0" /f

rem 1 - Configure Related Matches in Find on Page, the results are processed in a cloud service
reg add "%hkx%\%MSEdgePoliciesPath%" /v "RelatedMatchesCloudServiceEnabled" /t REG_DWORD /d "0" /f

rem 1 - Allow remote debugging
reg add "%hkx%\%MSEdgePoliciesPath%" /v "RemoteDebuggingAllowed" /t REG_DWORD /d "0" /f

rem 1 - Launches Renderer processes into an App Container for additional security benefits
reg add "%hkx%\%MSEdgePoliciesPath%" /v "RendererAppContainerEnabled" /t REG_DWORD /d "1" /f

rem 0 - Enable search in sidebar / 1 - DisableSearchInSidebarForKidsMode / 2 - DisableSearchInSidebar 
reg add "%hkx%\%MSEdgePoliciesPath%" /v "SearchInSidebarEnabled" /t REG_DWORD /d "2" /f

rem 1 - Allow Speech Recognition
reg add "%hkx%\%MSEdgePoliciesPath%" /v "SpeechRecognitionEnabled" /t REG_DWORD /d "0" /f

rem 1 - Allow Microsoft Edge Workspaces
reg add "%hkx%\%MSEdgePoliciesPath%" /v "EdgeWorkspacesEnabled" /t REG_DWORD /d "0" /f

rem 1 - DNS-based WPAD optimization (Web Proxy Auto-Discovery)
reg add "%hkx%\%MSEdgePoliciesPath%" /v "WPADQuickCheckEnabled" /t REG_DWORD /d "0" /f

rem 1 - The Sidebar appears in a fixed position on the Microsoft Windows desktop, and is hidden from the browser application frame
reg add "%hkx%\%MSEdgePoliciesPath%" /v "StandaloneHubsSidebarEnabled" /t REG_DWORD /d "0" /f

rem msdn: 
rem If you set this policy to 'ShareAllowed' (the default), users will be able to access 
rem the Share experience from the Settings and More Menu in Microsoft Edge to share with other apps on the system.
rem ShareAllowed (0) = Allow using the Share experience
rem ShareDisallowed (1) = Don't allow using the Share experience
reg add "%hkx%\%MSEdgePoliciesPath%" /v "ConfigureShare" /t REG_DWORD /d "1" /f

rem spotlight feature enable or disable.
reg add "%hkx%\%MSEdgePoliciesPath%" /v "EdgeCollectionsEnabled" /t REG_DWORD /d "0" /f

rem 
reg add "%hkx%\%MSEdgePoliciesPath%" /v "MathSolverEnabled" /t REG_DWORD /d "0" /f

rem 1 - The performance detector detects tab performance issues and recommends actions to fix the performance issues
reg add "%hkx%\%MSEdgePoliciesPath%" /v "PerformanceDetectorEnabled" /t REG_DWORD /d "0" /f

rem 1 - Pretty sure it's uneeded and/or unwanted.
reg add "%hkx%\%MSEdgePoliciesPath%" /v "WebWidgetAllowed" /t REG_DWORD /d "0" /f

rem 1 - Allow the Edge bar at Windows startup
reg add "%hkx%\%MSEdgePoliciesPath%" /v "WebWidgetIsEnabledOnStartup" /t REG_DWORD /d "0" /f


rem somewhat controverse: smartscreen.
rem 0 - Disable SmartScreen Filter in Microsoft Edge / 1 - Enable
rem enable in favor for more security. But all your URL requests will 
rem be sent to Microsoft servers and analyzed to answer if they are 'safe'.
reg add "%hkx%\%MSEdgePoliciesPath%" /v "SmartScreenEnabled" /t REG_DWORD /d "1" /f

rem Configure Microsoft Defender SmartScreen to block potentially unwanted apps
rem enable: 1, disable: 0.
reg add "%hkx%\%MSEdgePoliciesPath%" /v "SmartScreenPuaEnabled" /t REG_DWORD /d "1" /f

rem Ads setting for sites with intrusive ads / 1 - Allow ads on all sites / 2 - Block ads on sites with intrusive ads. (Default value)
reg add "%hkx%\%MSEdgePoliciesPath%" /v "AdsSettingForIntrusiveAdsSites" /t REG_DWORD /d "2" /f

rem Clipboard / 2 - BlockClipboard / 3 - AskClipboard
reg add "%hkx%\%MSEdgePoliciesPath%" /v "DefaultClipboardSetting" /t REG_DWORD /d "3" /f

rem File Editing / 2 - BlockFileSystemRead / 3 - AskFileSystemRead
reg add "%hkx%\%MSEdgePoliciesPath%" /v "DefaultFileSystemReadGuardSetting" /t REG_DWORD /d "2" /f

rem File Editing / 2 - BlockFileSystemWrite / 3 - AskFileSystemWrite
reg add "%hkx%\%MSEdgePoliciesPath%" /v "DefaultFileSystemWriteGuardSetting" /t REG_DWORD /d "2" /f

rem Location / 1 - AllowGeolocation / 2 - BlockGeolocation / 3 - AskGeolocation
reg add "%hkx%\%MSEdgePoliciesPath%" /v "DefaultGeolocationSetting" /t REG_DWORD /d "2" /f

rem Insecure Content / 2 - BlockInsecureContent / 3 - AllowExceptionsInsecureContent
reg add "%hkx%\%MSEdgePoliciesPath%" /v "DefaultInsecureContentSetting" /t REG_DWORD /d "2" /f

rem Notifications / 1 - AllowNotifications / 2 - BlockNotifications / 3 - AskNotifications
reg add "%hkx%\%MSEdgePoliciesPath%" /v "DefaultNotificationsSetting" /t REG_DWORD /d "2" /f

rem Motion or light sensors / 1 - AllowSensors / 2 - BlockSensors
reg add "%hkx%\%MSEdgePoliciesPath%" /v "DefaultSensorsSetting" /t REG_DWORD /d "2" /f

rem Serial ports / 2 - BlockSerial / 3 - AskSerial 
reg add "%hkx%\%MSEdgePoliciesPath%" /v "DefaultSerialGuardSetting" /t REG_DWORD /d "2" /f

rem USB Devices / 2 - BlockWebUsb / 3 - AskWebUsb
reg add "%hkx%\%MSEdgePoliciesPath%" /v "DefaultWebUsbGuardSetting" /t REG_DWORD /d "2" /f

rem Bluetooth / 2 - BlockWebBluetooth / 3 - AskWebBluetooth
reg add "%hkx%\%MSEdgePoliciesPath%" /v "DefaultWebBluetoothGuardSetting" /t REG_DWORD /d "2" /f

rem Access to HID devices via the WebHID API / 2 - BlockWebHid / 3 - AskWebHid
reg add "%hkx%\%MSEdgePoliciesPath%" /v "DefaultWebHidGuardSetting" /t REG_DWORD /d "2" /f

rem 1 - Allow extensions from other stores
reg add "%hkx%\%MSEdgePoliciesPath%" /v "ControlDefaultStateOfAllowExtensionFromOtherStoresSettingEnabled" /t REG_DWORD /d "0" /f

rem 1 - DeveloperToolsAllowed / 2 - DeveloperToolsDisallowed (Don't allow using the developer tools)
REM reg add "%hkx%\%MSEdgePoliciesPath%" /v "DeveloperToolsAvailability" /t REG_DWORD /d "2" /f

rem 1 - Blocks external extensions from being installed
reg add "%hkx%\%MSEdgePoliciesPath%" /v "BlockExternalExtensions" /t REG_DWORD /d "1" /f

rem 1 - Enable spellcheck
reg add "%hkx%\%MSEdgePoliciesPath%" /v "SpellcheckEnabled" /t REG_DWORD /d "0" /f

rem 1 - Offer to translate pages that aren't in a language I read
reg add "%hkx%\%MSEdgePoliciesPath%" /v "TranslateEnabled" /t REG_DWORD /d "0" /f

rem https://www.bleepingcomputer.com/news/security/google-microsoft-can-get-your-passwords-via-web-browsers-spellcheck
reg add "%hkx%\%MSEdgePoliciesPath%" /v "MicrosoftEditorProofingEnabled" /t REG_DWORD /d "0" /f
reg add "%hkx%\%MSEdgePoliciesPath%" /v "MicrosoftEditorSynonymsEnabled" /t REG_DWORD /d "0" /f

rem 1 - Browse as guest
reg add "%hkx%\%MSEdgePoliciesPath%" /v "BrowserGuestModeEnabled" /t REG_DWORD /d "0" /f

rem 1 - Allow users to configure Family safety and Kids Mode
reg add "%hkx%\%MSEdgePoliciesPath%" /v "FamilySafetySettingsEnabled" /t REG_DWORD /d "0" /f

rem 1 - Suggest similar sites when a website can't be found
reg add "%hkx%\%MSEdgePoliciesPath%" /v "AlternateErrorPagesEnabled" /t REG_DWORD /d "0" /f

rem Automatically switch to more secure connections with Automatic HTTPS / 0 - Disabled / 1 - Switch to supported domains / 2 - Always
reg add "%hkx%\%MSEdgePoliciesPath%" /v "AutomaticHttpsDefault" /t REG_DWORD /d "2" /f

rem Diagnostic Data / 0 - Off / 1 - RequiredData / 2 - OptionalData
reg add "%hkx%\%MSEdgePoliciesPath%" /v "DiagnosticData" /t REG_DWORD /d "0" /f

rem 1 - Use a web service to help resolve navigation errors
reg add "%hkx%\%MSEdgePoliciesPath%" /v "ResolveNavigationErrorsUseWebService" /t REG_DWORD /d "0" /f

rem 1 - Show me search and site suggestions using my typed characters
reg add "%hkx%\%MSEdgePoliciesPath%" /v "SearchSuggestEnabled" /t REG_DWORD /d "0" /f

rem 1 - Turn on site safety services to get more info about the sites you visit
reg add "%hkx%\%MSEdgePoliciesPath%" /v "SiteSafetyServicesEnabled" /t REG_DWORD /d "0" /f

rem 1 - Suggest group names when creating a new tab group
reg add "%hkx%\%MSEdgePoliciesPath%" /v "TabServicesEnabled" /t REG_DWORD /d "0" /f

rem 1 - Typosquatting Checker (just sending what you type to MS)
reg add "%hkx%\%MSEdgePoliciesPath%" /v "TyposquattingCheckerEnabled" /t REG_DWORD /d "0" /f

rem 1 - Visual search (sending what you are looking at to MS)
reg add "%hkx%\%MSEdgePoliciesPath%" /v "VisualSearchEnabled" /t REG_DWORD /d "0" /f

rem Enable Microsoft Search in Bing suggestions in the address bar
reg add "%hkx%\%MSEdgePoliciesPath%" /v "AddressBarMicrosoftSearchInBingProviderEnabled" /t REG_DWORD /d "0" /f

rem Allow personalization of ads, Microsoft Edge, search, news and other Microsoft services by sending browsing history, favorites and collections, usage and other browsing data to Microsoft
reg add "%hkx%\%MSEdgePoliciesPath%" /v "PersonalizationReportingEnabled" /t REG_DWORD /d "0" /f

rem Enable full-tab promotional content
reg add "%hkx%\%MSEdgePoliciesPath%" /v "PromotionalTabsEnabled" /t REG_DWORD /d "0" /f

rem Allow recommendations and promotional notifications from Microsoft Edge
reg add "%hkx%\%MSEdgePoliciesPath%" /v "ShowRecommendationsEnabled" /t REG_DWORD /d "0" /f

rem Choose whether users can receive customized background images and text, suggestions, notifications, and tips for Microsoft services)
rem Under investigation.
reg add "%hkx%\%MSEdgePoliciesPath%" /v "SpotlightExperiencesAndRecommendationsEnabled" /t REG_DWORD /d "0" /f

rem 1 - Let users compare the prices of a product they are looking at, get coupons or rebates from the website they're on
reg add "%hkx%\%MSEdgePoliciesPath%" /v "EdgeShoppingAssistantEnabled" /t REG_DWORD /d "0" /f

rem 1 - Show alerts when passwords are found in an online leak
reg add "%hkx%\%MSEdgePoliciesPath%" /v "PasswordMonitorAllowed" /t REG_DWORD /d "0" /f

rem 1 - Show Microsoft Rewards experience and notifications
reg add "%hkx%\%MSEdgePoliciesPath%" /v "ShowMicrosoftRewards" /t REG_DWORD /d "0" /f

rem 1 - Continue running background apps when Microsoft Edge is closed
reg add "%hkx%\%MSEdgePoliciesPath%" /v "BackgroundModeEnabled" /t REG_DWORD /d "0" /f

rem 1 - Startup boost
reg add "%hkx%\%MSEdgePoliciesPath%" /v "StartupBoostEnabled" /t REG_DWORD /d "0" /f

rem NetworkPrediction, msdn quote: 
rem NetworkPredictionAlways (0) = Predict network actions on any network connection
rem NetworkPredictionWifiOnly (1) = Not supported, if this value is used it will be treated as if 'Predict network actions on any network connection' (0) was set
rem NetworkPredictionNever (2) = Don't predict network actions on any network connection
reg add "%hkx%\%MSEdgePoliciesPath%" /v "NetworkPredictionOptions" /t REG_DWORD /d "2" /f


:: rewrite with copilot ai
:: https://learn.microsoft.com/en-us/deployedge/microsoft-edge-policies#composeinlineenabled
:: Data Type: Boolean
reg add "%hkx%\%MSEdgePoliciesPath%" /v "ComposeInlineEnabled" /t REG_DWORD /d 0 /f

:: https://learn.microsoft.com/en-us/deployedge/microsoft-edge-browser-policies/copilotpagecontext
reg add "%hkx%\%MSEdgePoliciesPath%" /v "CopilotPageContext" /t REG_DWORD /d 0 /f

:: https://learn.microsoft.com/en-us/deployedge/microsoft-edge-browser-policies/edgeentracopilotpagecontext
reg add "%hkx%\%MSEdgePoliciesPath%" /v "EdgeEntraCopilotPageContext" /t REG_DWORD /d 0 /f

:: https://learn.microsoft.com/en-us/deployedge/microsoft-edge-browser-policies/microsoft365copilotchaticonenabled
reg add "%hkx%\%MSEdgePoliciesPath%" /v "Microsoft365CopilotChatIconEnabled" /t REG_DWORD /d 0 /f

