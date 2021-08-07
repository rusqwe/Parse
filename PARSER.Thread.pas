unit PARSER.Thread;

interface

uses
  System.Classes, System.Generics.Collections, System.Math, System.SysUtils,
  System.Variants, System.DateUtils, System.Generics.Defaults, System.SyncObjs, IdHTTP;

type
  TCustomParseThread = class(TThread)
  private
    FURL: string;
    FLines, FId: integer;
    FExit, FIsWork: boolean;
    FCriticalSection: TCriticalSection;
    FAwayEvent: TGetStrProc;
    procedure SetURL(const Value: string);

  protected
    Reader: TIdHTTP;
    function ParseHTML(AURL: string): string; virtual;
    procedure Execute; override;

  public
    constructor Create(AId: integer; AURL: string; ThreadTerminated: TNotifyEvent; AwayEvent: TGetStrProc); reintroduce;
    destructor Destroy; override;
    property Stop: boolean write FExit;
    property URL: string write SetURL;
    property Id: integer read FId;
    property IsWork: boolean read FIsWork;
  end;

  TArtvidParseThread = class(TCustomParseThread)
  private
    function ParseHTML(AURL: string): string; override;
  end;

type
  TCustomManagerThread = class(TThread)
  private
    FParseThreads: TObjectList<TCustomParseThread>;  // TListThread <TCustomParseThread>
    FCountTh, FCountURL: integer;
    FExit: Boolean;
    FIsWork: ^Boolean;
    FLines: ^TStrings;
    FCriticalSection: TCriticalSection;
    FThValues: TStringList;
    procedure ThreadTerminated(Sender: TObject);
    procedure SetThValue(const AValues: string);
    procedure RunThread(AIndex: integer);
  protected
    procedure Execute; override;
    procedure BeginUpdate();
    procedure EndUpdate();
  public
    property Stop: boolean write FExit;
    constructor Create(ACountURL: integer; AIsWork: Pointer; ALines: Pointer); reintroduce;
    destructor Destroy; override;
  end;

implementation

uses MainFrm;

{ TCustomParseThread }

constructor TCustomParseThread.Create(AId: integer; AURL: string; ThreadTerminated: TNotifyEvent;
  AwayEvent: TGetStrProc);
begin
  inherited Create(false);
  FURL := AURL;
  FCriticalSection := TCriticalSection.Create;
  FreeOnTerminate := true;
  Reader := TIdHTTP.Create(nil); // FWork:=true;
  Reader.Request.AcceptCharSet := 'utf-8';
  FId := AId;
  FAwayEvent := AwayEvent;
  OnTerminate := ThreadTerminated;
end;

destructor TCustomParseThread.Destroy;
begin
  Reader.Free;
  FCriticalSection.Free;
  inherited Destroy;
end;

procedure TCustomParseThread.Execute;
var
  I: integer;
  OldURL, str: string;
begin
  while true do
  begin

    if FExit then
    begin
      Terminate;
      break;
    end;
    FIsWork := false;
    if FURL <> OldURL then
    begin
      OldURL := FURL;
      FIsWork := true;
      str := ParseHTML(FURL);
      // FAwayEvent(str);
      Synchronize(
        procedure
        begin
          // if Assigned(FAwayEvent) then
          FAwayEvent(str);
        end);
      sleep(1);
    end;
    sleep(1);
  end;

end;

function TCustomParseThread.ParseHTML(AURL: string): string;
begin
end;

procedure TCustomParseThread.SetURL(const Value: string);
begin
  // FCriticalSection.Enter;
  if FURL <> Value then
    FURL := Value;
  // FCriticalSection.Leave;
end;

{ TCustomManagerThread }

procedure TCustomManagerThread.BeginUpdate;
begin

end;

constructor TCustomManagerThread.Create(ACountURL: integer; AIsWork: Pointer; ALines: Pointer);
begin
  inherited Create(false);
  FIsWork := AIsWork;
  FLines := ALines;
  FCountURL := ACountURL;
  FCriticalSection := TCriticalSection.Create;
  FThValues := TStringList.Create();
  FreeOnTerminate := true;
end;

destructor TCustomManagerThread.Destroy;
begin
  FCriticalSection.Free;
  FThValues.Free;
  inherited Destroy;
end;

procedure TCustomManagerThread.EndUpdate;
begin

end;

procedure TCustomManagerThread.Execute;
var
  I, Y: integer;
  TimeStart, TimeStop: cardinal;
  Time: Extended;
begin
  TimeStart := GetTickCount;
  // FCriticalSection.Enter;
  FIsWork^ := true;
  // FCriticalSection.Leave;
  FParseThreads := TObjectList<TCustomParseThread>.Create();

  for I := 0 to 10 do
  begin
    FParseThreads.Add(TArtvidParseThread.Create(I, 'https://temp.artvid.ru/movie/' + IntToStr(I) + '.html',
      ThreadTerminated, SetThValue));
    inc(FCountTh);
  end;

  while true do
  begin
    if (I <= FCountURL) then
    begin
      // RunThread(I);
      sleep(5);
      for Y := 0 to FParseThreads.count - 1 do
        if not FParseThreads[Y].IsWork then
        begin
          FParseThreads[Y].URL := 'https://artvid.ru/movie/' + IntToStr(I) + '.html';
          inc(I);
        end;
    end;
    sleep(1);
    if (I >= FCountURL) or FExit then // and (FCount = 0))
    begin
      FExit := true;
      break;
    end;

  end;

  if FExit then
  begin
    for Y := 0 to 10 Do
      if (FParseThreads[Y] <> nil) and (not FParseThreads[Y].Terminated) then
      begin
        // FCriticalSection.Enter;
        FParseThreads[Y].Stop := true;
        // FCriticalSection.Leave;
      end;
  end;
  // Synchronize(endUpdate);
  while true do
  begin
    if FCountTh = 0 then
      break;

  end;

  TimeStop := GetTickCount;
  Time := (TimeStop - TimeStart) / 1000;
  Synchronize(
    procedure
    begin
      FLines.Assign(FThValues);
      FLines.Add('Œ ! ' + Time.ToString);
    end);
  FIsWork^ := false;
  Terminate;

  // PostMessage(Application.Handle, WM_QUIT, 0, 0);

end;

procedure TCustomManagerThread.RunThread(AIndex: integer);
begin
  FParseThreads[AIndex].Resume;
  inc(FCountTh);
end;

procedure TCustomManagerThread.SetThValue(const AValues: string);
begin
  // FCriticalSection.Enter;
  FThValues.Add(AValues);
  // FCriticalSection.Leave;
end;

procedure TCustomManagerThread.ThreadTerminated(Sender: TObject);
begin
  FCriticalSection.Enter;
  Dec(FCountTh);
  FCriticalSection.Leave;
end;

{ TArtvidParseThread }

function TArtvidParseThread.ParseHTML(AURL: string): string;
var
  html, Output: WideString;
  Name: string;
  CheckName: boolean;
  // posLink: integer;
begin
  Result := '';
  // posLink := 0;
  try
    html := Reader.Get(AURL);
    while true do
      // if not checkName then
      // if AnsiPos('<title>', WideString(html)) <> 0 then  begin
      // name := '';
      // Delete(html, 1, AnsiPos('<title>', WideString(html)) +
      // length('<title>') - 1);
      // name := copy(html, 1, pos('>', html) - 1);
      // end
      // else
      if AnsiPos('<a href=', WideString(html)) <> 0 then
      begin
        Output := '';
        Delete(html, 1, AnsiPos('<a href=', WideString(html)) + length('<a href=') - 1);
        Output := copy(html, 1, pos('>', html) - 1);
        if AnsiPos('ftp:', WideString(Output)) <> 0 then
        begin
          Result := Output;
          break;
        end;
      end
      else
        break;
    if Result <> '' then
      Delete(Result, length(Result) - 9, length(Result))
    else
      Result := 'Not found : ' + Id.ToString;
  except
    on E: Exception do
      Result := E.Message + ' : ' + Id.ToString;

  end;
end;

end.
