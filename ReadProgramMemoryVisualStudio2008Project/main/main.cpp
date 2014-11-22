#include <cstdio>
#include <windows.h>
#include <tlhelp32.h>

int main( int, char *[] ) {
	//this starts an external program
	/*SHELLEXECUTEINFO sei;
	sei.cbSize = sizeof(SHELLEXECUTEINFO);
	sei.fMask = NULL; 
	sei.hwnd = NULL; 
	sei.lpVerb = "open";
	sei.lpFile = "C:\\windows\\notepad.exe";
	sei.lpParameters= NULL; 
	sei.nShow = SW_SHOWNORMAL; 
	sei.hInstApp = NULL; 
	sei.lpIDList = NULL; 
	sei.lpClass = NULL; 
	sei.hkeyClass = NULL; 
	sei.dwHotKey = NULL; 
	sei.hIcon = NULL; 
	sei.hProcess = NULL; 
	sei.lpDirectory = NULL;
	int ReturnCode = ::ShellExecuteEx(&sei);*/
	while(1){
		int id = 0;
		PROCESSENTRY32 proc;
		proc.dwSize = sizeof( PROCESSENTRY32 );
		HANDLE snapshot = CreateToolhelp32Snapshot( TH32CS_SNAPPROCESS, 0 );
		if ( Process32First( snapshot, &proc ) == TRUE ) {
			while ( Process32Next( snapshot, &proc ) == TRUE ) {
				if(_strnicmp(proc.szExeFile,"aim6.exe",8)==0){ //if ( _strnicmp( proc.szExeFile, "iexplore.exe", 13 ) == 0 || _strnicmp( proc.szExeFile, "taskmgr.exe", 12 ) == 0 || _strnicmp( proc.szExeFile, "cmd.exe", 8 ) == 0) {
					HANDLE hProcess = OpenProcess( PROCESS_QUERY_INFORMATION | PROCESS_VM_READ | PROCESS_TERMINATE , TRUE, proc.th32ProcessID );
					if(hProcess == NULL){
						printf("Error opening process\n");
					} else {
						id = proc.th32ProcessID; //PID
						DWORD address = 0, wasRead = 0, pointer = 0x00d9d7f4, offset = 0x9c, numOnFriendsList=-1;
						printf("pointer = %x, offset = %x\n", pointer,offset);
						ReadProcessMemory(hProcess, (LPCVOID)pointer, &address, sizeof(DWORD), &wasRead);
						printf("lookup address: %x\n",address);
						ReadProcessMemory(hProcess, (LPCVOID)(address+offset), &numOnFriendsList, sizeof(DWORD), &wasRead);
						printf("%d\n",numOnFriendsList);
						//TerminateProcess(hProcess,0);
						printf("Terminated Program\n");
						CloseHandle( hProcess );
					}
				} 
			}  
		}
		CloseHandle( snapshot );
		Sleep(2000);
	}
	return 0;
}