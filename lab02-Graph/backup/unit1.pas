unit Unit1;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, FileUtil, TAGraph, TASeries, OpenGLContext, Forms,
  Controls, Graphics, Dialogs, ComCtrls, Grids, StdCtrls, Spin, ExtCtrls ,
  GL,GLU;
//opengl library
type

  { TForm1 }

  TForm1 = class(TForm)
    Button1: TButton;
    Chart1: TChart;
    Chart1LineSeries1: TLineSeries;
    Chart1LineSeries2: TLineSeries;
    FloatSpinEditL: TFloatSpinEdit;
    FloatSpinEditT10: TFloatSpinEdit;
    FloatSpinEditT90: TFloatSpinEdit;
    FloatSpinEditbeta: TFloatSpinEdit;
    Label6: TLabel;
    Label7: TLabel;
    Label8: TLabel;
    Memo1: TMemo;
    OpenGLControl1: TOpenGLControl;
    SpinEditN: TSpinEdit;
    FloatSpinEditU: TFloatSpinEdit;
    FloatSpinEditm: TFloatSpinEdit;
    FloatSpinEditT: TFloatSpinEdit;
    GroupBox1: TGroupBox;
    Label1: TLabel;
    Label2: TLabel;
    Label3: TLabel;
    Label4: TLabel;
    Label5: TLabel;
    PageControl1: TPageControl;
    ScrollBox1: TScrollBox;
    ScrollBox2: TScrollBox;
    ScrollBox3: TScrollBox;
    ScrollBox4: TScrollBox;
    StringGrid1: TStringGrid;
    TabSheet1: TTabSheet;
    TabSheet2: TTabSheet;
    TabSheet3: TTabSheet;
    Timer1: TTimer;
    procedure Button1Click(Sender: TObject);
    procedure OpenGLControl1Click(Sender: TObject);
    procedure OpenGLControl1MouseDown(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure OpenGLControl1MouseMove(Sender: TObject; Shift: TShiftState; X,
      Y: Integer);
    procedure OpenGLControl1MouseUp(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure OpenGLControl1Paint(Sender: TObject);
    procedure OpenGLControl1Resize(Sender: TObject);
    procedure Timer1Timer(Sender: TObject);
  private

  public

  end;

var
  Form1: TForm1;
  L,U,m,T,Gt1,Gt2 : Single;   //Graph1
  t10,t90,beta,dt : Single; //Graph2
  SSE : Real;
  N : Integer;
  //---OpenGL Variables-----
mStartX, mStartY : Integer;
alpha, betha, dx, dy : Single;
Tran_X, Tran_Y, Tran_Z : Single;
// ----plant Growth
GlobalT : Single ;
Localt : Single ;

implementation

{$R *.lfm}

{ TForm1 }

procedure TForm1.Button1Click(Sender: TObject);
var
  i : integer;
begin
   L := FloatSpinEditL.Value;
   U := FloatSpinEditU.Value;
   m := FloatSpinEditm.Value;
   T := FloatSpinEditT.Value;
   N := SpinEditN.Value;
   t10 := FloatSpinEditT10.Value;
   t90 := FloatSpinEditT90.Value;
   beta := FloatSpinEditBeta.Value;

   GlobalT := N;
   LOcalT := 0;

   Chart1LineSeries1.Clear;
   Chart1LineSeries2.Clear;
    dt := t90 - t10;
    SSE := 0;

   For i:=0 to N do
   begin
     Gt1 := L + (U-L)/(1+exp(m*(T-i)));
     Chart1LineSeries1.AddXY(i,Gt1,'',clRed);

     Gt2 := L + (U-L)/(1+exp((-ln(81)/dt)*(i-beta)));
     Chart1LineSeries2.AddXY(i,Gt2,'',clBlue);

     SSE := SSE + sqr(Gt1-Gt2);
   end;

  // Label9.Caption := 'SSE = ' + FloatToStr(SSE*10000000000) + 'x10E-10';
  Memo1.Lines.Text:= 'SSE =' + FloatToStr(SSE*10000000000) + 'x10E-10';
end;

procedure TForm1.OpenGLControl1Click(Sender: TObject);
begin

end;

procedure TForm1.OpenGLControl1MouseDown(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
begin
  Label1.Caption:=Format('down: %d, %d',[X,Y]);
  mStartX:=X;
  mStartY:=Y;
end;
                                       //พารามิเตอร์
procedure TForm1.OpenGLControl1MouseMove(Sender: TObject; Shift: TShiftState;
  X, Y: Integer);
begin
  //--Press Left & Right Mouse or Middle Mouse :Translate
  if ((ssLeft in Shift) and (ssRight in Shift)) or (ssMiddle in Shift) then
             // เมาส์ปุ่มขวากด เมาส์ปุ่มซ้ายกด
  begin
     Tran_X:=Tran_X+(X-mStartX)/1000;
     Tran_Y:=Tran_Y-(Y-mStartY)/1000;
     OpenGLControl1Paint(Sender);
end
   else //--Press Right Mouse : Zoom in/out
        if (ssRight in Shift) and (Not(ssLeft in Shift)) then
        //กดปุ่มซ้าายแล้วไม่กดปุ่มขวา
begin
     Tran_Z:=Tran_Z+(X-mStartX)/1000; // if /1000 use large number will move slow เมาส์ตั้งต้นห่างกันเท่าไหร่
     Tran_Z:=Tran_Z+(Y-mStartY)/1000;
     OpenGLControl1Paint(Sender);
end
   else //--Press Left Mouse only :Rotation
        if (ssLeft in Shift) and (Not(ssRight in Shift)) then
begin
     Label1.Caption:=Format('move: %d, %d',[X,Y]);
     dx:=(x-mStartX)/2;
     dy:=(y-mStartY)/2;
     OpenGLControl1Paint(Sender);
end;

end;

procedure TForm1.OpenGLControl1MouseUp(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
begin
  Label1.Caption:=Format('up: %d, %d',[X,Y]);
alpha:=alpha+dx;
dx:=0.0;
betha:=betha+dy;
dy:=0.0;

end;

procedure TForm1.OpenGLControl1Paint(Sender: TObject);
  var
Speed: Double;
begin
  //          R    G    U
glClearColor(0.0, 0.0, 0.0, 1.0);
glClear(GL_COLOR_BUFFER_BIT or GL_DEPTH_BUFFER_BIT); //ค่าคงตัว
glEnable(GL_DEPTH_TEST);

glMatrixMode(GL_PROJECTION);//การเตรียมเมททริกซ์โหมด
glLoadIdentity();//เมทริกซอเดรทีติ
// gluPerspective(45.0, double(OpenGLControl1.Width) / OpenGLControl1.height, 0.1, 100.0);
 //                         OpenGLControl1
gluPerspective(45.0, double(Width) / height, 0.1, 100.0);
glMatrixMode(GL_MODELVIEW);  //ดูตัวโมเดลที่เราวาด
glLoadIdentity();

glTranslatef(0.0, 0.0,-6.0);//เลื่อนไปทางจำนวนจริงแกน x y z

glTranslatef(Tran_X,Tran_Y,Tran_Z);
glRotatef(alpha+dx,0.0,1.0,0.0);  //ตัวกำหนดว่าหมุนแบบไหน หมุนเท่าไหร่ แกนอะไร
glRotatef(betha+dy,1.0,0.0,0.0);

// glRotatef(cube_rotationx, cube_rotationy, cube_rotationz, 0.0);
glBegin(GL_LINES); //เป็นตัวเนิ่มต้น
//--X-Axis
glColor3f(1.0,0.0,0.0);//การเปลี่ยนสีของพารามิเตอร์3ตัว
glVertex3f(-1.0,0.0,0.0);
glVertex3f( 1.0,0.0,0.0);
//--Y-Axis
glColor3f(0.0,1.0,0.0);
glVertex3f(0.0,-1.0,0.0);
glVertex3f(0.0,1.0,0.0);
//--Z-Axis
glColor3f(0.0,0.0,1.0);
glVertex3f(0.0,0.0,-1.0);
glVertex3f(0.0,0.0,1.0);
glEnd();
//---------The core of our implementation------  (หัวใจหลัก)
// U := 0.8;
// L := 0.2;
Gt1 := L + (U-L)/(1+exp(m*(T-LocalT)));

glLineWidth(5);
glBegin(GL_LINES);
glColor3f(0.1,0.8,0.2);
glVertex3f(0.0,0.0,0.0);
glVertex3f(0.0,2*Gt1,0.0);
glEnd();
       //leve1
glLineWidth(5);
glBegin(GL_POLYGON);
glColor3f(0.1,0.8,0.2);
glVertex3f(0.0,Gt1,0.0);
glVertex3f(0.1,Gt1+0.2,0.0);
glVertex3f(0.3,Gt1+0.3,0.0);
glVertex3f(0.2,Gt1+0.2,0.0);
glVertex3f(0.0,Gt1,0.0);
glEnd();
glLineWidth(1);
      //leve2
glLineWidth(5);
glBegin(GL_POLYGON);
glColor3f(0.1,0.8,0.2);
glVertex3f(0.0,0.5*Gt1,0.0);
glVertex3f(-0.1,0.5*Gt1+0.2,0.0);
glVertex3f(-0.3,0.5*Gt1+0.3,0.0);
glVertex3f(-0.2,0.5*Gt1+0.2,0.0);
glVertex3f(-0.0,0.5*Gt1,0.0);
glEnd();
glLineWidth(1);

//levetop
glLineWidth(5);
glBegin(GL_POLYGON);
glColor3f(0.1,0.8,0.2);
glVertex3f(0.0,2*Gt1,0.0);
glVertex3f(-0.05,2*Gt1+0.2,0.0);
glVertex3f(0.0,2*Gt1+0.3,0.0);
glVertex3f(0.05,2*Gt1+0.2,0.0);
glVertex3f(0.0,2*Gt1,0.0);
glEnd();
glLineWidth(1);
//---finalize with swap Buffer
OpenGLControl1.SwapBuffers;
end;

procedure TForm1.OpenGLControl1Resize(Sender: TObject);
begin

end;

procedure TForm1.Timer1Timer(Sender: TObject);
begin
    If LocalT >= GlobalT Then
LocalT := 0
Else
LocalT := LocalT + 0.1;

OpenGLControl1Paint(Sender);
end;

end.

