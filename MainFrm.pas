unit MainFrm;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants,
  System.Classes, Vcl.Graphics, DateUtils, Vcl.Controls, Vcl.Forms, Vcl.Dialogs,
  Vcl.StdCtrls, IdAntiFreezeBase,
  IdAntiFreeze, IdBaseComponent, IdComponent, IdTCPConnection, IdTCPClient,
  IdHTTP, System.Net.URLClient,
  System.Net.HttpClient, System.Net.HttpClientComponent, PARSER.Thread, Vcl.ExtCtrls;

type
  TMain = class(TForm)
    IdAntiFreeze1: TIdAntiFreeze;
    Memo1: TMemo;
    NetHTTPClient1: TNetHTTPClient;
    Panel1: TPanel;
    Button2: TButton;
    Button1: TButton;
    Button3: TButton;
    Edit1: TEdit;
    Button4: TButton;
    Label1: TLabel;
    procedure Button1Click(Sender: TObject);
    procedure Button2Click(Sender: TObject);
    procedure Button3Click(Sender: TObject);
    procedure Button4Click(Sender: TObject);
    procedure FormCloseQuery(Sender: TObject; var CanClose: Boolean);
  private
    test: TCustomManagerThread;
    isWork: boolean;
    function ParsingHTML(url: string; IdHTTP1: TIdHTTP): string;
    procedure test2(var p: pointer);
  public
  end;

var
  Main: TMain;

implementation

{$R *.dfm}

procedure TMain.Button1Click(Sender: TObject);
var
  i: integer;
  d1, d2: TDateTime;
  IdHTTP1: TIdHTTP;
begin
  d1 := now();
  IdHTTP1 := TIdHTTP.Create(self);
  IdHTTP1.Request.AcceptCharSet := 'utf-8';
  Memo1.Clear;
  for i := 1 to strtoint(Edit1.Text) do
  begin
    Memo1.Lines.Add(ParsingHTML('https://artvid.ru/movie/' + inttostr(i) +
      '.html', IdHTTP1));
  end;
  d2 := now();
  Label1.Caption := inttostr(MilliSecondsBetween(d2, d1)) + 'ms';
  IdHTTP1.Free;
end;

procedure TMain.Button2Click(Sender: TObject);
var
  i: integer;
begin

  test := TCustomManagerThread.Create(strtoint(Edit1.Text), @isWork, @Memo1.Lines);

end;

procedure TMain.Button3Click(Sender: TObject);
var
  v: integer;
  p: pointer;
begin
  v := 5;
  p := @v;
  Label1.Caption := (inttostr(integer(p^)));
  test2(p);
  Label1.Caption := Label1.Caption + ':' + inttostr(integer(p^));
end;

procedure TMain.Button4Click(Sender: TObject);
begin
Memo1.Clear;
end;

procedure TMain.FormCloseQuery(Sender: TObject; var CanClose: Boolean);
begin
  if Assigned(test) and isWork then
  begin
    test.Stop:= true;
    CanClose := false;
  end;
end;

procedure TMain.test2(var p: pointer);
var
  v: integer;
begin
  v := 5;
  p := @v;
end;

function TMain.ParsingHTML(url: string; IdHTTP1: TIdHTTP): string;
var
  html, output: WideString;
  // posLink: integer;
begin
  Result := '';
  // posLink := 0;
  try
    html := IdHTTP1.Get(url);
    while True do
      if AnsiPos('<a href=', WideString(html)) <> 0 then
      begin
        output := '';
        Delete(html, 1, AnsiPos('<a href=', WideString(html)) +
          length('<a href=') - 1);
        output := copy(html, 1, pos('>', html) - 1);
        if AnsiPos('ftp:', WideString(output)) <> 0 then
          Result := output;
      end
      else
        break;
    if Result <> '' then
      Delete(Result, length(Result) - 9, length(Result))
    else  Result := 'not found'
  except
    on E: Exception do
      Result := E.Message;
  end;
end;



// function fAnsiPos(const Substr, S: WideString; FromPos: integer): integer;
// var
// P: PChar;
// begin
// Result := 0;
// P := AnsiStrPos(PChar(S) + FromPos - 1, PChar(Substr));
// if P <> nil then
// Result := integer(P) - integer(PChar(S)) + 1;
// end;

end.
