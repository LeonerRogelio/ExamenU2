unit uData;

interface

uses
  System.SysUtils, System.Types, System.UITypes, System.Classes,
  System.Variants,
  FMX.Types, FMX.Controls, FMX.Forms, FMX.Graphics, FMX.Dialogs, FMX.Memo.Types,
  FMX.ScrollBox, FMX.Memo, FMX.StdCtrls, FMX.Controls.Presentation, FMX.Edit,
  System.IOUtils, FMX.DialogService, FMX.Platform;

type
  TfrmData = class(TForm)
    edtData: TEdit;
    btnBack: TButton;
    memLog: TMemo;
    Panel1: TPanel;
    TLtitulo: TLabel;
    procedure btnBackClick(Sender: TObject);
    procedure edtDataKeyUp(Sender: TObject; var Key: Word; var KeyChar: Char;
      Shift: TShiftState);
    procedure FormCloseQuery(Sender: TObject; var CanClose: Boolean);
    procedure FormCreate(Sender: TObject);
    procedure FormShow(Sender: TObject);

  private
    { Private declarations }
  public
    { Public declarations }
    autoArchivoNombre: String;
    function AppEvent(AAppEvent: TApplicationEvent; AContext: TObject): Boolean;
  end;

var
  frmData: TfrmData;
  // Para guardar el contenido del memo antes de ser modificado
  MemoOriginal: String;


implementation

{$R *.fmx}

uses uMain;

var
  opcion: boolean = false;
  dialogo: boolean = false;

procedure TfrmData.btnBackClick(Sender: TObject);
begin
  close;
end;

// Se activa al precionar la tecla 'Enter'.
procedure TfrmData.edtDataKeyUp(Sender: TObject; var Key: Word;
  var KeyChar: Char; Shift: TShiftState);
begin
  if Key = vkReturn then
  begin
    // Guardar el texto en el memo y limpiarlo
    memLog.Lines.Add(edtData.Text);
    edtData.Text := ''; // vacia el Tedit
  end;
end;

procedure TfrmData.FormCloseQuery(Sender: TObject; var CanClose: Boolean);
// var
// datos: String;
begin
  // // Si no ha abierto un dialogo entonces
  if dialogo = false then
  begin
    // Si esta la var MemoOriginal es diferente a lo que tiene el memo significa
    // que hubo cambios, entonce preguntar por guardar.
    if (MemoOriginal <> memLog.Text) then
    begin
      dialogo := true;
      TDialogService.MessageDialog('¿Desea Guardar los Cambios?',
        TMsgDlgType.mtConfirmation, [TMsgDlgBtn.mbYes, TMsgDlgBtn.mbNo,
        TMsgDlgBtn.mbCancel], TMsgDlgBtn.mbNo, 0,
        procedure(const AResult: TModalResult)
        begin
          dialogo := false;
          // Si el resultado es:
          case AResult of
            // Si: Guarda los cambios y cierra el Data (Abre el contenido de Main).
            mrYES:
              begin
                memLog.Lines.SaveToFile(frmMain.archivo);
                MemoOriginal := memLog.Text;
                TDialogService.ShowMessage('Datos guardados');
                opcion := true;
                {$IF DEFINED(ANDROID)}
                close;
                {$ENDIF}
              end;
            mrNo: // Cierra el Data (Abre el contenido de uMain).
              begin
                memLog.Text := MemoOriginal;
                opcion := true;
                {$IF DEFINED(ANDROID)}
                close;
                {$ENDIF}
              end;

            mrCancel: // No cerrar Data.
              begin
                opcion := false;
              end;
          end;
        end);
    end
    else
      opcion := true;
  end;
  CanClose := opcion;
end;

procedure TfrmData.FormCreate(Sender: TObject);
var
  AppEventSvc: IFMXApplicationEventService;

begin
  if TPlatformServices.Current.SupportsPlatformService
    (IFMXApplicationEventService, IInterface(AppEventSvc)) then
  begin
    AppEventSvc.SetApplicationEventHandler(AppEvent);
  end;
end;

procedure TfrmData.FormShow(Sender: TObject);
begin
  TLtitulo.Text := 'Archivo : ' + frmMain.nombreArchivo;
  // falso: No debe cerrar la ventana
  opcion := false;
  // Al inicio no existe dialogo
  dialogo := false;
  memLog.Lines.LoadFromFile(frmMain.archivo); // Carga el archivo.
  MemoOriginal := memLog.Text; // Crea una copia del memLog.
end;

// Guardar el contenido cuando se apaga el sistema operativo
function TfrmData.AppEvent(AAppEvent: TApplicationEvent;
AContext: TObject): Boolean;
begin
  var t := AAppEvent;
  case AAppEvent of
    //TApplicationEvent.WillTerminate :    //si se va a volver inactivo entoces:
    TApplicationEvent.WillBecomeInactive:
    begin
        memLog.Lines.SaveToFile(frmMain.autoArchivo);
        memLog.Text := frmMain.nombreArchivo;  //se borra el contenido y ahora se guarda solo el nombre
        memLog.Lines.SaveToFile(frmMain.nombres);
    end;
  end;
  Result := true;
end;

end.
