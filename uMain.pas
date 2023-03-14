unit uMain;

interface

uses
  System.SysUtils, System.Types, System.UITypes, System.Classes,
  System.Variants,
  System.IOUtils, // Para el Path.
  FMX.Types, FMX.Controls, FMX.Forms, FMX.Graphics, FMX.Dialogs, FMX.StdCtrls,
  FMX.Controls.Presentation,
  FMX.DialogService; // Para los dialogos.

type
  TfrmMain = class(TForm)
    lblMain: TLabel;
    btnShowFrmDatos: TButton;
    btnExit: TButton;
    procedure btnExitClick(Sender: TObject);
    procedure btnShowFrmDatosClick(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure FormCreate(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  var
    ruta: string;
    values: array [0 .. 0] of string; // Declaración de Matriz
    autoArchivo: string; // Para guardar SIN NECESIDAD DE PREGUNTAR.
    archivo: String; // Para guardar la ruta del dispositivo y el archivo.
    nombreArchivo: String; // Para guardar el nombre del archivo.
    Texto: TStringList;
    nombres: string;
  end;

var
  frmMain: TfrmMain;

implementation

{$R *.fmx}

uses uData;

procedure TfrmMain.FormCreate(Sender: TObject);
begin
  try
    Texto := TStringList.Create;
    autoArchivo := TPath.Combine(TPath.GetTempPath, 'autoguardado.txt');
    nombres := TPath.Combine(TPath.GetTempPath, 'editfile.txt');
    Texto.LoadFromFile(nombres);
  Except
    on A: Exception do
  end;
end;

procedure TfrmMain.FormShow(Sender: TObject);
begin
  if FileExists(autoArchivo) then
  begin
    TDialogService.MessageDialog
      ('Hay un archivo pendiente, ¿Desea continuar editando este documento?'
      // Mensaje
      , TMsgDlgType.mtConfirmation // tipo de dialogo
      , [TMsgDlgBtn.mbYes, TMsgDlgBtn.mbNo] // botones
      , TMsgDlgBtn.mbNo // default button
      , 0, // help context
      procedure(const AResult: TModalResult)
      begin
        case AResult of
          mrYES: // Mostrar 'frmData'
            begin
              nombreArchivo := Texto[0];
              archivo := TPath.Combine(TPath.GetTempPath, Texto[0]);
              frmData.memLog.Lines.LoadFromFile(autoArchivo);
              frmData.memLog.Lines.SaveToFile(archivo);
              DeleteFile(autoArchivo);
{$IF DEFINED (MSWINDOWS)}
              frmData.ShowModal;
{$ELSE IF(ANDROID)}
              frmData.Show;
{$ENDIF}
            end;
          mrNo:
            TDialogService.MessageDialog
              ('Advertencia : Los datos modificados se borraran'
              // mensaje del dialogo
              , TMsgDlgType.mtConfirmation // tipo de dialogo
              , [TMsgDlgBtn.mbYes, TMsgDlgBtn.mbNo]
              // botones
              , TMsgDlgBtn.mbNo // default button
              , 0, // help context
              procedure(const Resultado: TModalResult)
              begin
                case Resultado of // si el resultado es :
                  mrYES:
                    begin
                      frmData.memLog.Lines.Clear;
                      Texto.Clear;
                      DeleteFile(autoArchivo)
                    end;
                end; // case
              end); // procedure
        end; // case
      end); // procedure
  end;
end; // Fin procedure btnShowFrmDatosClick.

procedure TfrmMain.btnExitClick(Sender: TObject);
begin
  Close;
end;

// Al presionar el botón "Abrir archivo" pedir el nombre del archivo que desea abrir.
procedure TfrmMain.btnShowFrmDatosClick(Sender: TObject);
begin
  values[0] := 'Default1'; // Inicializar valores por defecto.
  // titulo del dialogo   // Labels      //valor inicial por defecto
  TDialogService.InputQuery('Abrir', ['Abrir archivo:'], values,
    procedure(const AResult: TModalResult; const values: array of string)
    begin
      case AResult of
        mrOk:
          begin
            nombreArchivo := values[0] + '.txt';
            ruta := TPath.GetTempPath; // Obtiene la ruta del dispositivo.
            archivo := TPath.Combine(ruta, nombreArchivo);
            // Obtiene el arrchivo.
            if FileExists(archivo) then
            begin
{$IF DEFINED (MSWINDOWS)}
              frmData.ShowModal;
{$ELSE IF(ANDROID)}
              frmData.Show;
{$ENDIF}
            end
            else
              // Mensaje del dialogo
              TDialogService.MessageDialog('El archivo: ' + nombreArchivo +
                ', no existe. ¿Desea crearlo?', TMsgDlgType.mtConfirmation
                // tipo de dialogo
                , [TMsgDlgBtn.mbYes, TMsgDlgBtn.mbNo] // Botones
                , TMsgDlgBtn.mbNo // default button
                , 0, // help context

                procedure(const Result: TModalResult)
                begin
                  case Result of
                    mrYES: // Guarda el nuevo archivo
                      begin
                        frmData.memLog.Lines.Clear;
                        // Vaciar memLog porque es un archivo nuevo.
                        frmData.memLog.Lines.SaveToFile(archivo);
                        // Guarda el contenido del 'memLog'.
{$IF DEFINED(MSWINDOWS)}
                        frmData.ShowModal; // Mostrar el 'frmData'.
{$ELSE IF(ANDROID)}
                        frmData.Show;
{$ENDIF}
                      end;
                  end;
                end);
          end; // Fin mrOk.
      end; // case AResult.
    end); // procedure(const AResult: TModalResult; const values: array of string).
end;
end.
