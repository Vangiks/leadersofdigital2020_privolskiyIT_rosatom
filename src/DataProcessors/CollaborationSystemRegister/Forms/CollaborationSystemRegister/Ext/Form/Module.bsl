&AtClient
Var ActivationCode;

&AtServer
Procedure OnCreateAtServer(Cancel, StandardProcessing)
	
	InfoBaseName = Metadata.Name;
	
EndProcedure

&AtClient
Procedure OnOpen(Cancel)
	
	RegistrationStatus = CollaborationSystem.InfoBaseRegistered();
	RegistrationStatusChanged();
	
	//ServerAddress = "ws://127.0.0.1:9094";
	
	ActivationCode = Format(CurrentDate(), "DF=""yyyyMMddHHmmss""");
	
EndProcedure

&AtClient
Procedure ServerAddressEditTextChange(Item, Text, StandardProcessing)
	
	SetButtonsEnable(Text, Email);
	
EndProcedure

&AtClient
Procedure EmailEditTextChange(Item, Text, StandardProcessing)
	
	SetButtonsEnable(ServerAddress, Text);

EndProcedure

&AtClient
Procedure Register(Command)
	
	RegistrationParameters = New CollaborationSystemInfoBaseRegistrationParameters();
	RegistrationParameters.ServerAddress = ServerAddress;
	RegistrationParameters.Email = Email;
	RegistrationParameters.InfoBaseName = InfoBaseName;
	
	RegistrationParameters.ActivationCode = ActivationCode;
	
	NotifyDescription = New NotifyDescription("RegistrationSuccessHandler",
								  ThisForm,
								  ,
								  "RegistrationErrorHandler",
								  ThisForm);
	CollaborationSystem.BeginInfoBaseRegistration(NotifyDescription, RegistrationParameters);

EndProcedure

&AtClient
Procedure Unregister(Command)

	NotifyDescription = New NotifyDescription("UnregistrationSuccessHandler",
								  ThisForm,
								  ,
								  "UnregistrationErrorHandler",
								  ThisForm);
	CollaborationSystem.BeginInfoBaseUnregistration(NotifyDescription);

EndProcedure

&AtClient
Procedure RefreshStatus(Command)
	
	RegistrationStatus = CollaborationSystem.InfoBaseRegistered();
	RegistrationStatusChanged();
	
EndProcedure

&AtClient
Procedure RegistrationSuccessHandler(RegistrationCompleted, MessageText, AdditionalParameters) Export 
	
	If RegistrationCompleted Then
		
		RegistrationStatus = True;
		RegistrationStatusChanged();
		
		ShowMessageBox(, 
			NStr("en = 'The infobase registration is complete'; ru = 'Регистрация информационной базы выполнена'"));
		
	Else
		
		ShowMessageBox(, MessageText);

	EndIf;
	
EndProcedure

&AtClient
Procedure RegistrationErrorHandler(ErrorInfo, StandardProcessing, AdditionalParameters) Export
	
	StandardProcessing = False;
	ShowMessageBox(, 
			NStr("en = 'Registration error: '; ru = 'Ошибка при регистрации: '") + 
			ErrorInfo.Description);
	
EndProcedure

&AtClient
Procedure UnregistrationSuccessHandler(AdditionalParameters) Export 
	
	RegistrationStatus = False;
	RegistrationStatusChanged();
	
	ShowMessageBox(, 
			NStr("en = 'The infobase registration is canceled'; ru = 'Регистрация информационной базы отменена'"));
	
EndProcedure

&AtClient
Procedure UnregistrationErrorHandler(ErrorInfo, StandardProcessing, AdditionalParameters) Export 
	
	StandardProcessing = False;
	ShowMessageBox(,
			NStr("en = 'Error canceling registration: '; ru = 'Ошибка при отмене регистрации: '") + 
			ErrorInfo.Description);
	
EndProcedure

&AtClient
Procedure RegistrationStatusChanged()
	
	RegistrationStatusString = ?(RegistrationStatus, 
		NStr("en = 'Information base is registered'; ru = 'Информационная база зарегистрирована'"),
		NStr("en = 'Information base is not registered'; ru = 'Информационная база не зарегистрирована'"));
	SetButtonsEnable(ServerAddress, Email);
	
EndProcedure

&AtClient
Procedure SetButtonsEnable(ServerAddress, Email)
	
	Items.Register.Enabled = 
		NOT RegistrationStatus AND 
		ValueIsFilled(ServerAddress) AND ValueIsFilled(Email);
		
	Items.Unregister.Enabled = RegistrationStatus;
	
EndProcedure

