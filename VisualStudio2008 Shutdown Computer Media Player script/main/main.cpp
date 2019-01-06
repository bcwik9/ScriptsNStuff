#include <cstdio>
#include <windows.h>
#include <tlhelp32.h>

int main( int, char *[] ) {
	int id = 0;
	int found = 0;
	int first = 1;
	printf("** Make sure you close this window if you do not want your computer\nto shut down when you close Windows Media Player **\n\n");
	PROCESSENTRY32 proc;
	proc.dwSize = sizeof( PROCESSENTRY32 );
	while(1){
		HANDLE snapshot = CreateToolhelp32Snapshot( TH32CS_SNAPPROCESS, 0 );
		if ( Process32First( snapshot, &proc ) == TRUE ) {
			while ( Process32Next( snapshot, &proc ) == TRUE ) {
				if(_strnicmp(proc.szExeFile,"wmplayer.exe",8)==0){
					HANDLE hProcess = OpenProcess( PROCESS_QUERY_INFORMATION | PROCESS_VM_READ | PROCESS_TERMINATE , TRUE, proc.th32ProcessID );
					if(hProcess == NULL){
						printf("Error opening process\n");
					} else {
						found = 1;
						id = proc.th32ProcessID; //PID
						CloseHandle( hProcess );
					}
				} 
			}  
		}
		CloseHandle( snapshot );
		if (first && !found) {
			found = 1;
			printf("ALERT: Windows Media Player has not been found, please start it or\nyour computer will shut down\n");
			system("pause");
		}
		first = 0;
		if (!found) {
			system("shutdown -s -t 0");
		}
		found = 0;
		Sleep(15000);
	}
	return 0;
}