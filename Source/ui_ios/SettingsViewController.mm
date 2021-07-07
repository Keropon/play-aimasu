#import "SettingsViewController.h"
#import "SettingsListSelectorViewController.h"
#include "../AppConfig.h"
#include "PreferenceDefs.h"
#include "../gs/GSH_OpenGL/GSH_OpenGL.h"

@implementation SettingsViewController

- (void)updateGsHandlerNameLabel
{
	int gsHandlerId = CAppConfig::GetInstance().GetPreferenceInteger(PREFERENCE_VIDEO_GS_HANDLER);
	switch(gsHandlerId)
	{
	default:
		[[fallthrough]];
	case PREFERENCE_VALUE_VIDEO_GS_HANDLER_OPENGL:
		[gsHandlerName setText:@"OpenGL"];
		break;
	case PREFERENCE_VALUE_VIDEO_GS_HANDLER_VULKAN:
		[gsHandlerName setText:@"Vulkan"];
		break;
	}
}

- (void)updateResolutionFactorLabel
{
	int factor = CAppConfig::GetInstance().GetPreferenceInteger(PREF_CGSH_OPENGL_RESOLUTION_FACTOR);
	[resolutionFactor setText:[NSString stringWithFormat:@"%dx", factor]];
}

- (void)viewDidLoad
{
	[showFpsSwitch setOn:CAppConfig::GetInstance().GetPreferenceBoolean(PREFERENCE_UI_SHOWFPS)];
	[showVirtualPadSwitch setOn:CAppConfig::GetInstance().GetPreferenceBoolean(PREFERENCE_UI_SHOWVIRTUALPAD)];
	[virtualPadOpacitySlider setValue:float(CAppConfig::GetInstance().GetPreferenceInteger(PREFERENCE_UI_VIRTUALPADOPACITY) / 100.0)];
	[hideVirtualPadWhenControllerConnected setOn:CAppConfig::GetInstance().GetPreferenceBoolean(PREFERENCE_UI_HIDEVIRTUALPAD_CONTROLLER_CONNECTED)];

	[self updateGsHandlerNameLabel];
	[self updateResolutionFactorLabel];
	[resizeOutputToWidescreen setOn:CAppConfig::GetInstance().GetPreferenceBoolean(PREF_CGSHANDLER_WIDESCREEN)];
	[forceBilinearFiltering setOn:CAppConfig::GetInstance().GetPreferenceBoolean(PREF_CGSH_OPENGL_FORCEBILINEARTEXTURES)];

	[enableAudioOutput setOn:CAppConfig::GetInstance().GetPreferenceBoolean(PREFERENCE_AUDIO_ENABLEOUTPUT)];

	NSString* versionString = [NSString stringWithFormat:@"%s - %s", PLAY_VERSION, __DATE__];
	versionInfoLabel.text = versionString;
}

- (void)viewDidDisappear:(BOOL)animated
{
	CAppConfig::GetInstance().SetPreferenceBoolean(PREFERENCE_UI_SHOWFPS, showFpsSwitch.isOn);
	CAppConfig::GetInstance().SetPreferenceBoolean(PREFERENCE_UI_SHOWVIRTUALPAD, showVirtualPadSwitch.isOn);
	CAppConfig::GetInstance().SetPreferenceBoolean(PREFERENCE_UI_HIDEVIRTUALPAD_CONTROLLER_CONNECTED, showVirtualPadSwitch.isOn);
	int prefValue = int(virtualPadOpacitySlider.value * 100.0);
	CAppConfig::GetInstance().SetPreferenceInteger(PREFERENCE_UI_VIRTUALPADOPACITY, prefValue);

	CAppConfig::GetInstance().SetPreferenceBoolean(PREF_CGSHANDLER_WIDESCREEN, resizeOutputToWidescreen.isOn);
	CAppConfig::GetInstance().SetPreferenceBoolean(PREF_CGSH_OPENGL_FORCEBILINEARTEXTURES, forceBilinearFiltering.isOn);

	CAppConfig::GetInstance().SetPreferenceBoolean(PREFERENCE_AUDIO_ENABLEOUTPUT, enableAudioOutput.isOn);

	CAppConfig::GetInstance().Save();

	if(self.completionHandler)
	{
		self.completionHandler();
	}
}

- (void)tableView:(UITableView*)tableView didSelectRowAtIndexPath:(NSIndexPath*)indexPath
{
	[tableView deselectRowAtIndexPath:indexPath animated:YES];
}

- (BOOL)shouldPerformSegueWithIdentifier:(NSString*)identifier sender:(id)sender
{
	if([identifier isEqualToString:@"showGsHandlerSelector"])
	{
		//We can't change the GS handler if the emulator is running in the background
		return (self.completionHandler == nil);
	}
}

- (void)prepareForSegue:(UIStoryboardSegue*)segue sender:(id)sender
{
	if([segue.identifier isEqualToString:@"showResolutionFactorSelector"])
	{
		SettingsListSelectorViewController* selector = (SettingsListSelectorViewController*)segue.destinationViewController;
		int factor = CAppConfig::GetInstance().GetPreferenceInteger(PREF_CGSH_OPENGL_RESOLUTION_FACTOR);
		selector.value = log2(factor);
	}
	else if([segue.identifier isEqualToString:@"showGsHandlerSelector"])
	{
		SettingsListSelectorViewController* selector = (SettingsListSelectorViewController*)segue.destinationViewController;
		selector.value = CAppConfig::GetInstance().GetPreferenceInteger(PREFERENCE_VIDEO_GS_HANDLER);
	}
}

- (IBAction)selectedGsHandler:(UIStoryboardSegue*)segue
{
	SettingsListSelectorViewController* selector = (SettingsListSelectorViewController*)segue.sourceViewController;
	CAppConfig::GetInstance().SetPreferenceInteger(PREFERENCE_VIDEO_GS_HANDLER, selector.value);
	[self updateGsHandlerNameLabel];
}

- (IBAction)selectedResolutionFactor:(UIStoryboardSegue*)segue
{
	SettingsListSelectorViewController* selector = (SettingsListSelectorViewController*)segue.sourceViewController;
	int factor = 1 << selector.value;
	CAppConfig::GetInstance().SetPreferenceInteger(PREF_CGSH_OPENGL_RESOLUTION_FACTOR, factor);
	[self updateResolutionFactorLabel];
}

- (IBAction)returnToParent
{
	[self.presentingViewController dismissViewControllerAnimated:YES completion:nil];
}

@end
