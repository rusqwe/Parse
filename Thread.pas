unit Thread;

interface

uses
  System.Classes, System.Generics.Collections, System.Math, System.SysUtils,
  System.Variants, System.DateUtils, System.Generics.Defaults,
  Winapi.Messages, Winapi.Windows, IdHTTP;

type
  TMyThread = class(TThread)
  private
    FURL, FReport: string;
    FLines, FNumber: integer;
    FExit, FWork: boolean;
    IdHTTP1: TIdHTTP;
    function ParsingHTML(url: string): string;
  protected
    procedure Execute; override;
    procedure UpdateMemo();
  public
    constructor Create(Number: integer; url: string;
      ThreadTerminated: TNotifyEvent); reintroduce;
    property StopThread: boolean write FExit;
    property SetURL: string write FURL;

  end;

type
  TStartThread = class(TThread)
  private
    FMyThreads: TObjectList<TMyThread>;
    FCount, FCountURL: integer;
    FExitProgram: boolean;
    FExit: boolean;
    FInWork: ^boolean;
    procedure ThreadTerminated(Sender: TObject);
    procedure RunThread(index: integer);
    // procedure ExitProgram();
  protected
    procedure Execute; override;
    procedure UpdateMemo1(count, time: integer);
    procedure BeginUpdate();
    procedure EndUpdate();
  public
    property StopThread: boolean write FExit;
    constructor Create(CountURL: integer; InWork: Pointer); reintroduce;
    destructor Destroy; override;
  end;

implementation



{ TMyThread }

constructor TMyThread.Create(Number: integer; url: string;
  ThreadTerminated: TNotifyEvent);
begin
  inherited Create(false);
  FURL := url;
  FreeOnTerminate := true;
  IdHTTP1 := TIdHTTP.Create(nil); // FWork:=true;
  IdHTTP1.Request.AcceptCharSet := 'utf-8';
  FNumber := Number;
  OnTerminate := ThreadTerminated;
end;

procedure TMyThread.Execute;
var
  I: integer;
  OldURL: string;
begin
  while true do
  begin

    if FExit then
    begin
      Terminate;
      break;
    end;
    FWork := false;
    if FURL <> OldURL then
    begin
      OldURL := FURL;
      FWork := true;
      FReport := ParsingHTML(FURL);
      Synchronize(UpdateMemo);
      sleep(5);
    end;
    sleep(1);
  end;
  IdHTTP1.Free;

end;

function TMyThread.ParsingHTML(url: string): string;
var
  html, output: WideString;
  name: string;
  checkName:boolean;
  // posLink: integer;
begin
  Result := '';
  // posLink := 0;
  try
    html := IdHTTP1.Get(url);
    while true do
//      if not checkName then
//        if AnsiPos('<title>', WideString(html)) <> 0 then  begin
//          name := '';
//          Delete(html, 1, AnsiPos('<title>', WideString(html)) +
//          length('<title>') - 1);
//          name := copy(html, 1, pos('>', html) - 1);
//        end
//      else
      if AnsiPos('<a href=', WideString(html)) <> 0 then
      begin
        output := '';
        Delete(html, 1, AnsiPos('<a href=', WideString(html)) +
          length('<a href=') - 1);
        output := copy(html, 1, pos('>', html) - 1);
        if AnsiPos('ftp:', WideString(output)) <> 0 then
        begin
          Result := output;
          break;
        end;
      end
      else
        break;
    if Result <> '' then
      Delete(Result, length(Result) - 9, length(Result))
    else  Result := 'not found'
  except
    on E: Exception do
      Result := E.Message + ' : ' + IntToStr(FNumber);

  end;

end;

procedure TMyThread.UpdateMemo();
begin

end;

{ TStartThread }

procedure TStartThread.BeginUpdate;
begin

end;

constructor TStartThread.Create(CountURL: integer; InWork: Pointer);
begin
  inherited Create(false);
  FInWork := InWork;
  FCountURL := CountURL;
  FreeOnTerminate := true;
end;

destructor TStartThread.Destroy;
begin

  inherited Destroy;
end;

procedure TStartThread.EndUpdate;
begin

end;

procedure TStartThread.Execute;
var
  I, y: integer;
begin
  FInWork^:=true;
  FMyThreads := TObjectList<TMyThread>.Create();

  for I := 0 to 10 do
  begin
    FMyThreads.Add(TMyThread.Create(I, 'https://temp.artvid.ru/movie/' + inttostr(I) +
      '.html', ThreadTerminated));
    inc(FCount);
  end;
  // i:= 0;

  while true do
  begin
    if (I <= FCountURL) then // (FCount < 10) and
    begin
      // RunThread(I);
      sleep(10);
      for y := 0 to FMyThreads.count - 1 do
        if not FMyThreads[y].FWork then
        begin
          FMyThreads[y].SetURL := 'https://artvid.ru/movie/' + inttostr(I)
            + '.html';
          inc(I);
          sleep(2);
        end;

    end;
    sleep(0);
    if (I >= FCountURL) or FExit then // and (FCount = 0))
    begin
      FExit := true;
      break;
    end;

  end;

  if FExit then
  begin
    for y := 0 to  10 Do
      if (FMyThreads[y] <> nil) and (not FMyThreads[y].Terminated) then
      begin
        FMyThreads[y].StopThread := true;
      end;
  end;
  // Synchronize(endUpdate);
  while true do
  begin
    if FCount = 0 then
      break;

  end;
  FInWork^:=false;
  Terminate;
  // if FExit then
  // PostMessage(Application.Handle, WM_QUIT, 0, 0);

end;

procedure TStartThread.RunThread(index: integer);
begin
  FMyThreads[index].Resume;
  inc(FCount);
end;

procedure TStartThread.ThreadTerminated(Sender: TObject);
begin
  Dec(FCount);
  // Synchronize((Sender as TMyThread).UpdateMemo2);
end;

procedure TStartThread.UpdateMemo1(count, time: integer);
begin

end;

end.
