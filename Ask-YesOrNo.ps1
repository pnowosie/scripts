# Description: Ask a user to answer a question with either yes or no.
#PFE: http://www.peetersonline.nl/2009/07/user-confirmation-in-powershell/
 
# Example use: 
# If (Ask-YesOrNo)
# 	{ 
#	# User has confirmed
#	...
#	}
#	Else
#	{
#	# User did not confirm
#	...
#	}
 
Function Ask-YesOrNo
	{
	param([string]$title="Confirm",[string]$message="Are you sure?")
	$choiceYes = New-Object System.Management.Automation.Host.ChoiceDescription "&Yes", "Answer Yes."
	$choiceNo = New-Object System.Management.Automation.Host.ChoiceDescription "&No", "Answer No."
	$options = [System.Management.Automation.Host.ChoiceDescription[]]($choiceYes, $choiceNo)
	$result = $host.ui.PromptForChoice($title, $message, $options, 1)
		switch ($result)
    	{
			0 
			{
			Return $true
			}
 
			1 
			{
			Return $false
			}
		}
	}