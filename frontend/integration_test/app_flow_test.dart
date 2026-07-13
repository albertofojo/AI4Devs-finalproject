// Test E2E del flujo principal de XANEE (HU-01..HU-06) sobre la UI real.
//
// El contenido vive en test/flow_e2e_test.dart para poder ejecutarse headless en
// CI con `flutter test --platform chrome`. Este fichero lo re-expone bajo
// integration_test/ (estructura de la plantilla) y permite ejecutarlo también en
// un navegador/dispositivo real con `flutter test integration_test/`.
import '../test/flow_e2e_test.dart' as e2e;

void main() => e2e.main();
