// The installer's one-screen interface, included in GitWolf.iss's [Code] section. The standard pages
// stay underneath and do the work; their notebook is hidden and these controls are drawn over the window
// instead. The pages that ask a question (files in use, restart needed) are shown as Inno Setup draws them.

const
  ViewWidth = 480;
  ViewHeight = 440;
  ContentWidth = 360;
  Margin = 24;

var
  Logo: TBitmapImage;
  Title, Subtitle, Status, FolderLabel, VersionLabel: TNewStaticText;
  FolderButton: TNewButton;
  DesktopCheck, OpenCheck: TNewCheckBox;

function WantsDesktopIcon: Boolean;
begin
  Result := DesktopCheck.Checked;
end;

procedure Place(Control: TControl; Left, Top, Width, Height: Integer);
begin
  Control.SetBounds(ScaleX(Left), ScaleY(Top), ScaleX(Width), ScaleY(Height));
end;

procedure Centre(Text: TNewStaticText; Caption: String; Top: Integer);
begin
  Text.Caption := Caption;
  Text.Top := ScaleY(Top);
  Text.Left := (WizardForm.ClientWidth - Text.Width) div 2;
end;

function NewText(Size: Integer): TNewStaticText;
begin
  Result := TNewStaticText.Create(WizardForm);
  Result.Parent := WizardForm;
  Result.Font.Size := Size;
end;

function NewCheck(Caption: String): TNewCheckBox;
begin
  Result := TNewCheckBox.Create(WizardForm);
  Result.Parent := WizardForm;
  Result.Caption := Caption;
end;

procedure ShowFolder;
begin
  FolderLabel.Caption := 'Install to  ' + MinimizePathName(WizardForm.DirEdit.Text, FolderLabel.Font, ScaleX(280));
end;

procedure ChooseFolder(Sender: TObject);
var
  Folder: String;
begin
  Folder := ExtractFileDir(WizardForm.DirEdit.Text);
  if BrowseForFolder('Choose where to install GitWolf.', Folder, True) then
  begin
    // Always a folder of its own, unless the one chosen already is.
    if CompareText(ExtractFileName(RemoveBackslashUnlessRoot(Folder)), 'GitWolf') <> 0 then
      Folder := AddBackslash(Folder) + 'GitWolf';
    WizardForm.DirEdit.Text := Folder;
    ShowFolder;
  end;
end;

procedure LoadLogo;
var
  Name: String;
begin
  if ScaleX(100) >= 175 then Name := 'logo-200.bmp'
  else if ScaleX(100) >= 125 then Name := 'logo-150.bmp'
  else Name := 'logo-100.bmp';
  ExtractTemporaryFile(Name);
  Logo.Bitmap.LoadFromFile(ExpandConstant('{tmp}\') + Name);
end;

function SetWindowLong(Window: HWND; Index: Integer; Value: Longint): Longint;
  external 'SetWindowLongW@user32.dll stdcall';
function CallWindowProc(Previous: Longint; Window: HWND; Msg: UINT; WParam, LParam: Longint): Longint;
  external 'CallWindowProcW@user32.dll stdcall';

const
  GWL_WNDPROC = -4;
  WM_NCHITTEST = $0084;
  HTCLIENT = 1;
  HTCAPTION = 2;

var
  PreviousWindowProc: Longint;

// Without a title bar, the window is moved by dragging its background: Windows is told that the
// background is a title bar.
function DraggableWindowProc(Window: HWND; Msg: UINT; WParam, LParam: Longint): Longint;
begin
  Result := CallWindowProc(PreviousWindowProc, Window, Msg, WParam, LParam);
  if (Msg = WM_NCHITTEST) and (Result = HTCLIENT) then
    Result := HTCAPTION;
end;

procedure DeinitializeSetup;
begin
  // Handed back before the script that answers it is unloaded.
  if PreviousWindowProc <> 0 then
    SetWindowLong(WizardForm.Handle, GWL_WNDPROC, PreviousWindowProc);
end;

procedure InitializeWizard;
var
  Grown, Taller: Integer;
begin
  // Before sizing, so that the client area is measured without the frame.
  WizardForm.BorderStyle := bsNone;

  Grown := ScaleX(ViewWidth) - WizardForm.ClientWidth;
  Taller := ScaleY(ViewHeight) - WizardForm.ClientHeight;
  WizardForm.ClientWidth := ScaleX(ViewWidth);
  WizardForm.ClientHeight := ScaleY(ViewHeight);
  WizardForm.Left := WizardForm.Left - Grown div 2;
  WizardForm.Top := WizardForm.Top - Taller div 2;

  Logo := TBitmapImage.Create(WizardForm);
  Logo.Parent := WizardForm;
  Logo.Stretch := True;
  Place(Logo, (ViewWidth - 96) div 2, 32, 96, 96);
  LoadLogo;

  Title := NewText(22);
  Title.Font.Style := [fsBold];
  Subtitle := NewText(10);
  Status := NewText(9);
  FolderLabel := NewText(9);
  VersionLabel := NewText(9);
  VersionLabel.Caption := 'Version {#AppVersion}';

  FolderButton := TNewButton.Create(WizardForm);
  FolderButton.Parent := WizardForm;
  FolderButton.Caption := 'Change...';
  FolderButton.OnClick := @ChooseFolder;

  DesktopCheck := NewCheck('Create a desktop shortcut');
  // Kept on when a reinstall finds the shortcut already there.
  DesktopCheck.Checked := FileExists(ExpandConstant('{autodesktop}\GitWolf.lnk'));
  OpenCheck := NewCheck('Open GitWolf now');
  OpenCheck.Checked := True;

  WizardForm.NextButton.Parent := WizardForm;
  WizardForm.CancelButton.Parent := WizardForm;
  WizardForm.ProgressGauge.Parent := WizardForm;

  // Last, because changing the frame or a parent can replace the window.
  PreviousWindowProc := SetWindowLong(WizardForm.Handle, GWL_WNDPROC, CreateCallback(@DraggableWindowProc));
end;

procedure CurPageChanged(CurPageID: Integer);
var
  Start, Working, Done, Standard: Boolean;
begin
  Start := CurPageID = wpWelcome;
  Working := CurPageID = wpInstalling;
  Done := (CurPageID = wpFinished) and not WizardForm.YesRadio.Visible;
  Standard := not (Start or Working or Done);

  WizardForm.OuterNotebook.Visible := Standard;
  WizardForm.Bevel.Visible := False;
  WizardForm.BeveledLabel.Visible := False;
  WizardForm.BackButton.Visible := False;

  Logo.Visible := not Standard;
  Title.Visible := not Standard;
  Subtitle.Visible := not Standard;
  Status.Visible := Working;
  FolderLabel.Visible := Start;
  FolderButton.Visible := Start;
  VersionLabel.Visible := Start;
  DesktopCheck.Visible := Start;
  OpenCheck.Visible := Done;
  WizardForm.ProgressGauge.Visible := Working;

  if Standard then
  begin
    // Their own buttons, in the usual corner.
    Place(WizardForm.NextButton, ViewWidth - 208, ViewHeight - 42, 88, 28);
    Place(WizardForm.CancelButton, ViewWidth - 112, ViewHeight - 42, 88, 28);
    Exit;
  end;

  if Done then
  begin
    Centre(Title, 'You''re all set', 144);
    Centre(Subtitle, 'GitWolf {#AppVersion} is installed.', 192);
    Place(OpenCheck, (ViewWidth - 140) div 2, 236, 160, 22);
    WizardForm.NextButton.Caption := 'Finish';
  end
  else
  begin
    Centre(Title, 'GitWolf', 144);
    Centre(Subtitle, 'Your repositories, always in sync.', 192);
    WizardForm.NextButton.Caption := 'Install';
  end;

  if Working then
  begin
    Centre(Status, 'Installing...', 248);
    Place(WizardForm.ProgressGauge, (ViewWidth - ContentWidth) div 2, 274, ContentWidth, 8);
    Place(WizardForm.CancelButton, (ViewWidth - 120) div 2, 312, 120, 30);
  end
  else if Done then
    Place(WizardForm.NextButton, (ViewWidth - 240) div 2, 280, 240, 40)
  else
  begin
    Place(WizardForm.NextButton, (ViewWidth - 240) div 2, 234, 240, 40);
    // Kept, because without it the window's close button does nothing.
    Place(WizardForm.CancelButton, (ViewWidth - 240) div 2, 282, 240, 30);
    Place(FolderButton, ViewWidth - Margin - 88, 356, 88, 28);
    FolderLabel.Left := ScaleX(Margin);
    FolderLabel.Top := ScaleY(362);
    ShowFolder;
    Place(DesktopCheck, Margin, 396, 220, 22);
    VersionLabel.Left := ScaleX(ViewWidth - Margin) - VersionLabel.Width;
    VersionLabel.Top := ScaleY(399);
  end;
end;

function NextButtonClick(CurPageID: Integer): Boolean;
var
  Code: Integer;
begin
  Result := True;
  // A silent installation never starts the program.
  if (CurPageID = wpFinished) and not WizardSilent and OpenCheck.Visible and OpenCheck.Checked then
    if not Exec(ExpandConstant('{app}\{#Program}'), '', ExpandConstant('{app}'), SW_SHOWNORMAL, ewNoWait, Code) then
      MsgBox('GitWolf was installed but couldn''t be opened. Start it from the Start menu.', mbInformation, MB_OK);
end;
