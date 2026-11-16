// The uninstaller's "Also delete my list?" dialog, included from
// wayfinch.iss (and shown on its own by a preview script while testing).
// Needs the DeleteData* custom messages.

{ Asks (with a checkbox, off by default) whether to delete the list too.
  Returns whether the box was ticked. }
function AskDeleteData(): Boolean;
var
  Form: TSetupForm;
  Check: TNewCheckBox;
  Note: TNewStaticText;
  OkButton: TNewButton;
begin
  // Keep the size given here: without KeepSizeX/Y, Inno scales custom forms
  // up with the wizard and the dialog ends up huge and mostly empty.
  Form := CreateCustomForm(ScaleX(440), ScaleY(120), True, True);
  try
    Form.Caption := CustomMessage('DeleteDataTitle');

    Check := TNewCheckBox.Create(Form);
    Check.Parent := Form;
    Check.Left := ScaleX(16);
    Check.Top := ScaleY(16);
    Check.Width := Form.ClientWidth - ScaleX(32);
    Check.Height := ScaleY(20);
    Check.Caption := CustomMessage('DeleteDataCheck');
    Check.Checked := False;

    Note := TNewStaticText.Create(Form);
    Note.Parent := Form;
    Note.Left := ScaleX(16);
    Note.Top := Check.Top + Check.Height + ScaleY(6);
    Note.Width := Form.ClientWidth - ScaleX(32);
    Note.AutoSize := False;
    Note.WordWrap := True;
    Note.Caption := CustomMessage('DeleteDataNote');
    // As tall as the wrapped text, whatever the language and font size.
    Note.AdjustHeight();

    OkButton := TNewButton.Create(Form);
    OkButton.Parent := Form;
    OkButton.Width := ScaleX(80);
    OkButton.Height := ScaleY(25);
    OkButton.Left := Form.ClientWidth - OkButton.Width - ScaleX(16);
    OkButton.Top := Note.Top + Note.Height + ScaleY(14);
    // The dialog ends just below the button.
    Form.ClientHeight := OkButton.Top + OkButton.Height + ScaleY(12);
    OkButton.Caption := SetupMessage(msgButtonOK);
    OkButton.ModalResult := mrOk;
    OkButton.Default := True;

    Form.ActiveControl := OkButton;
    Form.ShowModal();
    Result := Check.Checked;
  finally
    Form.Free();
  end;
end;
