unit bbp2unit;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, FileUtil, Forms, Controls, Graphics, Dialogs, Spin,
  StdCtrls, Clipbrd, Menus;

type

  { TForm1 }

  TForm1 = class(TForm)
    Button_paste: TButton;
    Button_toClipboard: TButton;
    Button_set: TButton;
    CheckBox_addserial_cmdB: TCheckBox;
    CheckBox_space: TCheckBox;
    ComboBox_datavalue: TComboBox;
    ComboBox_DataLen: TComboBox;
    ComboBox_AddrLen: TComboBox;
    ComboBox_BCCcode: TComboBox;
    ComboBox_OpCode: TComboBox;
    Edit_serialcommand: TEdit;
    Edit_BCC: TEdit;
    Edit_BFE: TEdit;
    Edit_data: TEdit;
    Edit_registeroffset: TEdit;
    Edit_addressregister: TEdit;
    Edit_Addresshex: TEdit;
    Edit_DataLen: TEdit;
    Edit_FTF: TEdit;
    Edit_BFS: TEdit;
    GroupBox_serialcommand: TGroupBox;
    GroupBox_data: TGroupBox;
    GroupBox_Address: TGroupBox;
    GroupBox_DataLen: TGroupBox;
    GroupBox_FTF_BinaryCode: TGroupBox;
    Label_decimal: TLabel;
    Label_datavalue: TLabel;
    Label_BCC: TLabel;
    Label_BFE: TLabel;
    Label_data: TLabel;
    Label_decimal1: TLabel;
    Label_registeroffset: TLabel;
    Label_registeraddress: TLabel;
    Label_Address: TLabel;
    Label_textDataLen: TLabel;
    Label_DataLen: TLabel;
    Label_AddrLen: TLabel;
    Label_BCBcode: TLabel;
    Label_FTF: TLabel;
    Label_BFS: TLabel;
    Label_OpCode: TLabel;
    Label_textaddrlen: TLabel;
    Label_textbcccode: TLabel;
    Label_textopcode: TLabel;
    MainMenu: TMainMenu;
    MenuItem_About: TMenuItem;
    MenuItem_Help: TMenuItem;
    MenuItem_exit: TMenuItem;
    MenuItem_File: TMenuItem;
    SpinEdit_datalen: TSpinEdit;
    SpinEdit_data: TSpinEdit;
    procedure Button_pasteClick(Sender: TObject);
    procedure Button_setClick(Sender: TObject);
    procedure Button_toClipboardClick(Sender: TObject);
    procedure CheckBox_addserial_cmdBChange(Sender: TObject);
    procedure CheckBox_spaceChange(Sender: TObject);
    procedure ComboBox_AddrLenChange(Sender: TObject);
    procedure ComboBox_BCCcodeChange(Sender: TObject);
    procedure ComboBox_DataLenChange(Sender: TObject);
    procedure ComboBox_datavalueChange(Sender: TObject);
    procedure ComboBox_OpCodeChange(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure MenuItem_aboutClick(Sender: TObject);
    procedure MenuItem_exitClick(Sender: TObject);
    procedure SpinEdit_dataChange(Sender: TObject);
    procedure SpinEdit_datalenChange(Sender: TObject);
  private
    { private declarations }
  public
    procedure CalcFTF();
    { public declarations }
  end;

var
  Form1: TForm1;

implementation

{$R *.lfm}

{ TForm1 }

function HexStringToInt(hexnum:string):integer;
var
 s:char; s_ord:integer; i, j:integer;  hnum:integer; sixteen: integer;
begin
     result:=0; hnum:=0;
     for i:=length(hexnum) downto 1 do begin
         s:=hexnum[i]; s_ord:=ord(s);
         case s_ord of
              ord('0') : hnum:=0;
              ord('1') : hnum:=1;
              ord('2') : hnum:=2;
              ord('3') : hnum:=3;
              ord('4') : hnum:=4;
              ord('5') : hnum:=5;
              ord('6') : hnum:=6;
              ord('7') : hnum:=7;
              ord('8') : hnum:=8;
              ord('9') : hnum:=9;
              ord('A') : hnum:=10;
              ord('a') : hnum:=10;
              ord('B') : hnum:=11;
              ord('b') : hnum:=11;
              ord('C') : hnum:=12;
              ord('c') : hnum:=12;
              ord('D') : hnum:=13;
              ord('d') : hnum:=13;
              ord('E') : hnum:=14;
              ord('e') : hnum:=14;
              ord('F') : hnum:=15;
              ord('f') : hnum:=15;
         end; {case}
         if i=length(hexnum) then result:=hnum  {simulate exponential function}
         else begin
             sixteen:=1;
             for j:=length(hexnum)-i downto 1 do
             sixteen := sixteen * 16;
             result:=result + (hnum * sixteen);
         end;

      end;  {for loop}
end; {hext to int function}


function StringToHex(S: String): string;
var I: Integer;
begin
  Result:= '';
  for I := 1 to length (S) do
    Result:= Result+IntToHex(ord(S[i]),2);
end;

function HexToString(H: String): String;
var I: Integer;
begin
  Result:= '';
  for I := 1 to length (H) div 2 do
    Result:= Result+Char(StrToInt('$'+Copy(H,(I-1)*2+1,2)));
end;


function DecToBin(n:int64):string;
var s:string;
begin
s:='';
while n<>0 do
  begin
   s:=chr(n mod 2 +ord('0'))+s;
   n:=n div 2;
  end;
result:=s;
end;

function DecToHex(n:int64):string;
var s:string;
    c:char;
begin
s:='';
while n<>0 do
  begin
   if n mod 16 <10 then c:=chr(n mod 16+ord('0'))
                   else c:=chr(n mod 16+ord('A')-10);
   s:=c+s;
   n:=n div 16;
  end;
result:=s;
end;

function HexToDec(s:string):int64;
var p:int64;
    c,i:integer;
begin
 p:=0;
 for i:=1 to length(s) do
  begin
   case s[i] of
     '0'..'9':c:=ord(s[i])-ord('0');
     'A'..'E':c:=ord(s[i])-ord('A')+10;
     'a'..'e':c:=ord(s[i])-ord('a')+10;
   else
   //error
   begin result:=-1;exit end;
   end;
   p:=p*16+c;
   end;
 result:=p;
end;

//ref:http://www.delphipages.com/forum/showthread.php?t=109062
function BinToDec(s : string) : Int64;
var i:integer;
begin
result:=0;
for i:=1 to length(s) do
result:=result*2+strtoint(s[i]);
end;

function BinToHex(s : string) : string;
const m : array [0..15] of char= '0123456789ABCDEF';
var dec : Int64;
i : integer;
Begin
dec:=BinToDec(s);
result:='';
while dec>0 do begin
result:=m[dec - dec shr 4 shl 4]+result;
dec:=dec shr 4;
end;
End;

function XorStr(Stri, Strk: String): String;
var
    Longkey: string;
    I: Integer;
    Next: char;
begin
    for I := 0 to (Length(Stri) div Length(Strk)) do
    Longkey := Longkey + Strk;
    for I := 1 to length(Stri) do
    begin
        Next := chr((ord(Stri[i]) xor ord(Longkey[i])));
        Result := Result + Next;
    end;
end;

function xorStrings(Str1, Str2: String): String;
var
    i: Integer;
    s: String;
begin
    ShowMessage('str1:'+ IntToStr(Length(Str1)) + ' str2:'+ IntToStr(Length(Str2)));
    if Length(Str1) < 8 then begin
       for i:=1 to 8 - Length(Str1) do begin
          Str1 := '0' + Str1;
       end;
    end;
    //ShowMessage('Str1:' +Str1);
    if Length(Str2) < 8 then begin
       for i:=1 to 8 - Length(Str2) do begin
          Str2 := '0' + Str2;
       end;
    //ShowMessage('Str2:' +Str2);
    end;
    for i := 1 to Length(Str1) do begin
        if (Str1[i]='1') and (Str2[i]='1') then s:='0'
        else if (Str1[i]='1') and (Str2[i]='0') then s:='1'
        else if (Str1[i]='0') and (Str2[i]='1') then s:='1'
        else if (Str1[i]='0') and (Str2[i]='0') then s:='0';
        Result := Result + s;
    end;
    ShowMessage('Result:'+ IntToStr(Length(Result)));
   { if Length(Result) < 8 then begin
       for i:=1 to 8 - Length(Result) do begin
          Result := '0' + Result;
       end;
    end; }
end;

procedure TForm1.CalcFTF();
var
   binstring: String;
   intstring: Integer;
   //i : Integer;
   xorsum: String;
   a, d: String;

   saddress: String;
   iaddress: Integer;
   i,j, k, l : Integer;
   revAddress : String;
begin

  Edit_addressregister.Text:= StringReplace(Edit_addressregister.Text, '0x', '',[rfReplaceAll, rfIgnoreCase]);
  Edit_addressregister.Text:= StringReplace(Edit_addressregister.Text, '0X', '',[rfReplaceAll, rfIgnoreCase]);
  Edit_addressregister.Text:= StringReplace(Edit_addressregister.Text, 'x', '',[rfReplaceAll, rfIgnoreCase]);
  Edit_addressregister.Text:= StringReplace(Edit_addressregister.Text, 'X', '',[rfReplaceAll, rfIgnoreCase]);
  Edit_addressregister.Text:=TrimRight(Edit_addressregister.Text);
  iaddress:=HexToDec(Edit_addressregister.Text) + HexToDec(Edit_registeroffset.Text);
  saddress:=DecToHex(iaddress);
  if Length(saddress) <> Length(Edit_addressregister.Text) then begin
     j:=Length(Edit_addressregister.Text)-Length(saddress);
     for k:=0 to j do begin
        saddress:= '0' + saddress;
     end;
  end;
  i:=Length(saddress);

  if ComboBox_AddrLen.Text='00' then l:=4
  else if ComboBox_AddrLen.Text='01' then l:=8
  else if ComboBox_AddrLen.Text='10' then l:=12
  else if ComboBox_AddrLen.Text='11' then l:=16;

  if i < l then begin
     for k:=1 to l-i do begin
        saddress:='0' + saddress;
     end;
  end;
  i:=Length(saddress);

  //ShowMessage(IntToStr(i));
  While i >= 0 do begin
      revAddress:=revAddress+saddress[i-1]+saddress[i];
      i:=i-2;
  end;
  Edit_Addresshex.Text:=revAddress;


   binstring:=ComboBox_OpCode.Text+ComboBox_BCCcode.Text+ComboBox_AddrLen.Text;
   Edit_FTF.Text:=BinToHex(binstring);
   if Length(Edit_FTF.Text) = 1 then Edit_FTF.Text:='0' + Edit_FTF.Text;
   if Length(Edit_FTF.Text) = 0 then Edit_FTF.Text:='00' + Edit_FTF.Text;

   //Edit_Data.Text:='';
                           //Write
  { if ComboBox_OpCode.Text='00000' then begin
      for i:=1 to StrToInt(Edit_DataLen.Text)*2 do begin
          Edit_data.Text:=Edit_data.Text+'0';
      end;
   end
   else begin
      Edit_data.Text:='';
   end;  }

   if ComboBox_BCCcode.Text='1' then begin
      xorsum:='';
      //De neste linjene her tar for seg eksemplet i Basler dokumentet og fungerer osm det skal
       //ender opp med BCB som hex 66.
     { xorsum:=xorStrings(DecToBin(HexToDec('05')),DecToBin(HexToDec('04'))); //FTF xor DataLen
      xorsum:=xorStrings(DecToBin(HexToDec(xorsum)),DecToBin(HexToDec('64')));
      xorsum:=xorStrings(DecToBin(HexToDec(BinToHex(xorsum))),DecToBin(HexToDec('01')));
      xorsum:=xorStrings(DecToBin(HexToDec(BinToHex(xorsum))),DecToBin(HexToDec('03')));
      xorsum:=xorStrings(DecToBin(HexToDec(BinToHex(xorsum))),DecToBin(HexToDec('00')));
      xorsum:=xorStrings(DecToBin(HexToDec(BinToHex(xorsum))),DecToBin(HexToDec('01')));
      xorsum:=xorStrings(DecToBin(HexToDec(BinToHex(xorsum))),DecToBin(HexToDec('00')));
      xorsum:=xorStrings(DecToBin(HexToDec(BinToHex(xorsum))),DecToBin(HexToDec('00')));
      xorsum:=xorStrings(DecToBin(HexToDec(BinToHex(xorsum))),DecToBin(HexToDec('00')));
      ShowMessage(xorsum);
      Edit_BCC.Text:=BinToHex(xorsum); }

     { //Read eksempelet
      xorsum:=xorStrings(DecToBin(HexToDec('0D')),DecToBin(HexToDec('04')));//FTF xor DataLen
      //ShowMessage(xorsum);
      xorsum:=xorStrings(DecToBin(HexToDec(BinToHex(xorsum))),DecToBin(HexToDec('64')));
      //ShowMessage(xorsum);
      xorsum:=xorStrings(DecToBin(HexToDec(BinToHex(xorsum))),DecToBin(HexToDec('01')));
      //ShowMessage(xorsum);
      xorsum:=xorStrings(DecToBin(HexToDec(BinToHex(xorsum))),DecToBin(HexToDec('03')));
      //ShowMessage(xorsum);
      xorsum:=xorStrings(DecToBin(HexToDec(BinToHex(xorsum))),DecToBin(HexToDec('00')));
      //ShowMessage(xorsum);
      Edit_BCC.Text:=BinToHex(xorsum);   }




      //FTF xor DataLen
      {xorsum:=xorStrings(DecToBin(HexToDec(Edit_FTF.Text)),DecToBin(HexToDec(Edit_DataLen.Text)));
      ShowMessage(DecToBin(HexToDec(Edit_FTF.Text)));
      ShowMessage('rett tilbake:' + xorsum);
      i := 1;
      a:=Edit_Addresshex.Text;
      while i <= Length(Edit_Addresshex.Text) do begin
         xorsum:=xorStrings(DecToBin(HexToDec(BinToHex(xorsum))),DecToBin(HexToDec(a[i]+a[i+1])));
         i:=i+2;
      end;
      if Edit_data.Enabled = True then begin //Write er valgt
         i := 1;
         d:=Edit_data.Text;
         while i <= Length(Edit_data.Text) do begin
            xorsum:=xorStrings(DecToBin(HexToDec(BinToHex(xorsum))),DecToBin(HexToDec(d[i]+d[i+1])));
            i:=i+2;
         end;
      end;
      ShowMessage(xorsum);
      Edit_BCC.Text:=BinToHex(xorsum);
      }

     //xorsum:=xorStrings(DecToBin(HexToDec(Edit_FTF.Text)),DecToBin(HexToDec(Edit_DataLen.Text)));
     xorsum:= IntTohex(HexStringToInt(Edit_FTF.Text) xor HexStringToInt(Edit_DataLen.Text),1);
     //ShowMessage(DecToBin(HexToDec(Edit_FTF.Text)));
      //ShowMessage('rett tilbake:' + xorsum);
      i := 1;
      a:=Edit_Addresshex.Text;
      while i <= Length(Edit_Addresshex.Text) do begin
         //xorsum:=xorStrings(DecToBin(HexToDec(BinToHex(xorsum))),DecToBin(HexToDec(a[i]+a[i+1])));
         xorsum:= IntTohex( HexStringToInt(xorsum) xor HexStringToInt(a[i]+a[i+1]),1);
         i:=i+2;
      end;
      if Edit_data.Enabled = True then begin //Write er valgt
         i := 1;
         d:=Edit_data.Text;
         while i <= Length(Edit_data.Text) do begin
           // xorsum:=xorStrings(DecToBin(HexToDec(BinToHex(xorsum))),DecToBin(HexToDec(d[i]+d[i+1])));
           xorsum:= IntTohex( HexStringToInt(xorsum) xor HexStringToInt(d[i]+d[i+1]),1);
          i:=i+2;
         end;
      end;
      //ShowMessage(xorsum);
      if Length(xorsum) = 1 then xorsum:='0'+xorsum;
      Edit_BCC.Text:=xorsum;
   end
   else begin
      Edit_BCC.Text:='';
   end;

   Edit_serialcommand.Text:=Edit_BFS.Text+Edit_FTF.Text+Edit_DataLen.Text+Edit_Addresshex.Text;
   if Edit_data.Enabled = True then  Edit_serialcommand.Text:=Edit_serialcommand.Text+Edit_data.Text;
   Edit_serialcommand.Text:=Edit_serialcommand.Text+Edit_BCC.Text+Edit_BFE.Text;

   //Space between hex numbers, EDT style
   saddress:=Edit_serialcommand.Text;
   i:=1;
   revAddress:='';
   if CheckBox_space.Checked = True then begin
      While i <= Length(saddress) do begin
          revAddress:=revAddress+saddress[i]+saddress[i+1] + ' ';
          i:=i+2;
      end;
      Edit_serialcommand.Text:= TrimRight(revAddress);
   end;

   if CheckBox_addserial_cmdB.Checked = True then begin
      Edit_serialcommand.Text:='serial_cmd -B "' +Edit_serialcommand.Text+'"';
   end;

end;

procedure TForm1.FormCreate(Sender: TObject);
var
    i : Integer;
begin
  ComboBox_OpCode.Text:=ComboBox_OpCode.Items[0];
  Label_OpCode.Caption:='Write';
  ComboBox_BCCcode.Text:=ComboBox_BCCcode.Items[0];
  Label_BCBcode.Caption:='BCB OFF';
  ComboBox_AddrLen.Text:=ComboBox_AddrLen.Items[1];
  Label_AddrLen.Caption:='32 bits (= 4 bytes)';
  for i:=0 to 255 do begin
     ComboBox_DataLen.Items.Add(IntToStr(i));
  end;
  ComboBox_DataLen.Text:=ComboBox_DataLen.Items[4];
  for i:=0 to 1024 do begin
     ComboBox_datavalue.Items.Add(IntToStr(i));
  end;
  ComboBox_datavalue.Text:=ComboBox_datavalue.Items[1];

end;


procedure TForm1.MenuItem_aboutClick(Sender: TObject);
begin
  ShowMessage('bbp2, helper program to make Basler Binary Protocol version 2 serial commands.' + #13#10 +  #13#10 +

              'Bugs: sigurd@dagestad.info' + #13#10 + #13#10 +
              'Copyright (c) 2015, Sigurd Dagestad' + #13#10 +
'All rights reserved.' + #13#10 + #13#10 +

'Redistribution and use in source and binary forms, with or without '  +
'modification, are permitted provided that the following conditions are met: ' + #13#10 +
'    * Redistributions of source code must retain the above' + #13#10 +
'       copyright notice, this list of conditions and the' + #13#10 +
'       following disclaimer.' + #13#10 +
'    * Redistributions in binary form must reproduce the' + #13#10 +
'       above copyright notice, this list of conditions and' + #13#10 +
'       the following disclaimer in the documentation and/or' + #13#10 +
'       other materials provided with the distribution.' + #13#10 +
'    * Neither the name of ''Sigurd Dagestad'' nor the names of' + #13#10 +
'       its contributors may be used to endorse or promote' + #13#10 +
'       products derived from this software without specific' + #13#10 +
'       prior written permission.' + #13#10 + #13#10 +

'THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND ' +
'ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED ' +
'WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE '  +
'DISCLAIMED. IN NO EVENT SHALL ''Sigurd Dagestad'' BE LIABLE FOR ANY ' +
'DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES ' +
'(INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; ' +
'LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ' +
'ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT ' +
'(INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS ' +
'SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE. '
  );
end;

procedure TForm1.MenuItem_exitClick(Sender: TObject);
begin
  Close;
end;

procedure TForm1.SpinEdit_dataChange(Sender: TObject);
var
    datavalue, revAddress : String;
    l, i : Integer;
begin
  datavalue:=IntToHex(SpinEdit_data.Value, SpinEdit_datalen.Value*2 );
  if Length(datavalue) = 1 then datavalue:='0' + datavalue;
  if SpinEdit_datalen.Value <> 0 then begin
     for i:=Length(datavalue) to  SpinEdit_datalen.Value do begin
         datavalue:='00' + datavalue;
     end;
     i:=Length(datavalue);
     while i >= 0 do begin
        revAddress:=revAddress+datavalue[i-1]+datavalue[i];
        i:=i-2;
     end;
     Edit_data.Text:=revAddress; //IntToHex(StrToInt(ComboBox_datavalue.Text),1);
  end
  else Edit_data.Text:='';
  CalcFTF();
end;

procedure TForm1.SpinEdit_datalenChange(Sender: TObject);
begin
  Edit_DataLen.Text:=IntToHex(SpinEdit_datalen.Value,2);
  SpinEdit_dataChange(Sender);
end;

procedure TForm1.ComboBox_OpCodeChange(Sender: TObject);
begin
  if ComboBox_OpCode.Text='00000' then begin
     Label_OpCode.Caption:='Write';
     Edit_data.Enabled:=True;
  end
  else if ComboBox_OpCode.Text='00001' then begin
     Label_OpCode.Caption:='Read';
     Edit_data.Enabled:=False;
  end
  else if ComboBox_OpCode.Text='00010' then begin
     Label_OpCode.Caption:='Read Response';
     Edit_data.Enabled:=False;
  end;
  CalcFTF();
end;

procedure TForm1.ComboBox_BCCcodeChange(Sender: TObject);
begin
  if ComboBox_BCCcode.Text='0' then Label_BCBcode.Caption:='BCC OFF'
  else if ComboBox_BCCcode.Text='1' then Label_BCBcode.Caption:='BCC ON';
  CalcFTF();
end;

procedure TForm1.ComboBox_DataLenChange(Sender: TObject);
begin
  Edit_DataLen.Text:=IntToHex(StrToInt(ComboBox_DataLen.Text),2);
  ComboBox_datavalueChange(Sender);
  //CalcFTF();
end;

procedure TForm1.ComboBox_datavalueChange(Sender: TObject);
var
    datavalue, revAddress : String;
    l, i : Integer;
begin
  //datavalue:=IntToHex(StrToInt(ComboBox_datavalue.Text),1);
  datavalue:=IntToHex(StrToInt(ComboBox_datavalue.Text), StrToInt(ComboBox_DataLen.Text)*2 );
  if Length(datavalue) = 1 then datavalue:='0' + datavalue;
  for i:=Length(datavalue) to StrToInt(ComboBox_DataLen.Text) do begin
      datavalue:='00' + datavalue;
  end;
  i:=Length(datavalue);
  while i >= 0 do begin
     revAddress:=revAddress+datavalue[i-1]+datavalue[i];
     i:=i-2;
  end;
  Edit_data.Text:=revAddress; //IntToHex(StrToInt(ComboBox_datavalue.Text),1);
  CalcFTF();
end;

procedure TForm1.ComboBox_AddrLenChange(Sender: TObject);
begin
  if ComboBox_AddrLen.Text='00' then Label_AddrLen.Caption:='16 bits (= 2 bytes)'
  else if ComboBox_AddrLen.Text='01' then Label_AddrLen.Caption:='32 bits (= 4 bytes)'
  else if ComboBox_AddrLen.Text='10' then Label_AddrLen.Caption:='48 bits (= 6 bytes)'
  else if ComboBox_AddrLen.Text='11' then Label_AddrLen.Caption:='64 bits (= 8 bytes)';
  CalcFTF();
end;

procedure TForm1.Button_setClick(Sender: TObject);
var
    saddress: String;
    iaddress: Integer;
    i,j, k, l : Integer;
    revAddress : String;
begin
 {   Edit_addressregister.Text:= StringReplace(Edit_addressregister.Text, '0x', '',[rfReplaceAll, rfIgnoreCase]);
    Edit_addressregister.Text:= StringReplace(Edit_addressregister.Text, '0X', '',[rfReplaceAll, rfIgnoreCase]);
    Edit_addressregister.Text:= StringReplace(Edit_addressregister.Text, 'x', '',[rfReplaceAll, rfIgnoreCase]);
    Edit_addressregister.Text:= StringReplace(Edit_addressregister.Text, 'X', '',[rfReplaceAll, rfIgnoreCase]);
    iaddress:=HexToDec(Edit_addressregister.Text) + HexToDec(Edit_registeroffset.Text);
    saddress:=DecToHex(iaddress);
    if Length(saddress) <> Length(Edit_addressregister.Text) then begin
       j:=Length(Edit_addressregister.Text)-Length(saddress);
       for k:=0 to j do begin
          saddress:= '0' + saddress;
       end;
    end;
    i:=Length(saddress);

    if ComboBox_AddrLen.Text='00' then l:=4
    else if ComboBox_AddrLen.Text='01' then l:=8
    else if ComboBox_AddrLen.Text='10' then l:=12
    else if ComboBox_AddrLen.Text='11' then l:=16;

    if i < l then begin
       for k:=1 to l-i do begin
          saddress:='0' + saddress;
       end;
    end;
    i:=Length(saddress);

    //ShowMessage(IntToStr(i));
    While i >= 0 do begin
        revAddress:=revAddress+saddress[i-1]+saddress[i];
        i:=i-2;
    end;
    Edit_Addresshex.Text:=revAddress; }
    CalcFTF();
end;

procedure TForm1.Button_pasteClick(Sender: TObject);
begin
   Edit_addressregister.Text:=Clipboard.AsText;
end;

procedure TForm1.Button_toClipboardClick(Sender: TObject);
begin
  CalcFTF();
  Clipboard.AsText:=Edit_serialcommand.Text;
end;

procedure TForm1.CheckBox_addserial_cmdBChange(Sender: TObject);
begin
   CalcFTF();
end;

procedure TForm1.CheckBox_spaceChange(Sender: TObject);
begin
  if CheckBox_space.Checked = True then CheckBox_addserial_cmdB.Enabled:=True
  else begin
     CheckBox_addserial_cmdB.Checked:=False;
     CheckBox_addserial_cmdB.Enabled:=False;
  end;
  CalcFTF();
end;

end.

