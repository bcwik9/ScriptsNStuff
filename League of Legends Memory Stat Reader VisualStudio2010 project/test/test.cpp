// test.cpp : main project file.

#include "stdafx.h"
#include <windows.h>
#include <iostream>
#include <conio.h>
#include <cstdio>
#include <tlhelp32.h>
#pragma comment(lib, "user32.lib")
#pragma comment(lib, "Winmm.lib")


using namespace std;

int main(array<System::String ^> ^args)
{
	PROCESSENTRY32 proc;
	proc.dwSize = sizeof( PROCESSENTRY32 );
	char *process_name = "League of Legends.exe";
	printf("Waiting for LoL game process to start...\n");
	while(true){
		HANDLE snapshot = CreateToolhelp32Snapshot( TH32CS_SNAPPROCESS, 0 );
		if ( Process32First( snapshot, &proc ) == TRUE ) {
			while ( Process32Next( snapshot, &proc ) == TRUE ) {
				if(strncmp(proc.szExeFile,process_name,8)==0){
					HANDLE hProcess = OpenProcess( PROCESS_QUERY_INFORMATION | PROCESS_VM_READ | PROCESS_TERMINATE , TRUE, proc.th32ProcessID );
					if(hProcess == NULL){
						printf("Error opening process\n");
					} else {
						//old base addresses
						//int base_address = 0x009d0214;
						//int base_address = 0x009e4d44;

						int base_address = 0x009e7fb4;
						DWORD pid;
						printf("Attached to process!\nWaiting for game to load...\n");
						bool hp_sound_played = false;
						bool mana_sound_played = false;
						bool game_started = false;
						bool dead = false;
						int mana_address,hp_address,gold_address,max_hp_address,max_mana_address,lvl_address,skill_point_address;
						int hp, mana,max_hp, max_mana,gold, percent_health,percent_mana,lvl,skill_points;
						double percent;
						while(true){
							Sleep(1000);
							//calculating address to read current mana
							ReadProcessMemory(hProcess,(LPVOID)base_address,&mana_address,sizeof(int),0);
							mana_address = mana_address + 0xcc;
							ReadProcessMemory(hProcess,(LPVOID)mana_address,&mana_address,sizeof(int),0);
							mana_address = mana_address + 0x148;
							//calculating address to read current hp
							ReadProcessMemory(hProcess,(LPVOID)base_address,&hp_address,sizeof(int),0);
							hp_address = hp_address + 0xdc;
							ReadProcessMemory(hProcess,(LPVOID)hp_address,&hp_address,sizeof(int),0);
							hp_address = hp_address + 0x1c8;
							//calculating address to read gold
							ReadProcessMemory(hProcess,(LPVOID)base_address,&gold_address,sizeof(int),0);
							gold_address = gold_address + 0xc8;
							ReadProcessMemory(hProcess,(LPVOID)gold_address,&gold_address,sizeof(int),0);
							gold_address = gold_address + 0xf0;
							//calculating address to read max hp
							ReadProcessMemory(hProcess,(LPVOID)base_address,&max_hp_address,sizeof(int),0);
							max_hp_address= max_hp_address + 0xcc;
							ReadProcessMemory(hProcess,(LPVOID)max_hp_address,&max_hp_address,sizeof(int),0);
							max_hp_address = max_hp_address + 0x144;
							//calculating address to read max mana
							ReadProcessMemory(hProcess,(LPVOID)base_address,&max_mana_address,sizeof(int),0);
							max_mana_address = max_mana_address + 0xcc;
							ReadProcessMemory(hProcess,(LPVOID)max_mana_address,&max_mana_address,sizeof(int),0);
							max_mana_address = max_mana_address + 0x14c;
							//calculating address to read level
							ReadProcessMemory(hProcess,(LPVOID)base_address,&lvl_address,sizeof(int),0);
							lvl_address = lvl_address + 0xc8;
							ReadProcessMemory(hProcess,(LPVOID)lvl_address,&lvl_address,sizeof(int),0);
							lvl_address = lvl_address + 0xf4;
							//calculating address to read available ability points to spend
							ReadProcessMemory(hProcess,(LPVOID)base_address,&skill_point_address,sizeof(int),0);
							skill_point_address = skill_point_address + 0xcc;
							ReadProcessMemory(hProcess,(LPVOID)skill_point_address,&skill_point_address,sizeof(int),0);
							skill_point_address = skill_point_address + 0x178;
							gold=-1;
							while(true){
								ReadProcessMemory(hProcess,(LPVOID)lvl_address,&lvl,sizeof(int),0);
								if(game_started){
									if(lvl > -1){
										printf("Level %d: ",lvl,skill_points);
									}
								}
								ReadProcessMemory(hProcess,(LPVOID)hp_address,&hp,sizeof(int),0);
								if(game_started){
									if(hp > -1){
										printf("HP=%d",hp);
									}
								}
								ReadProcessMemory(hProcess,(LPVOID)max_hp_address,&max_hp,sizeof(int),0);
								if(game_started){
									if(max_hp > -1){
										printf("/%d ",max_hp);
									}
									if(max_hp != 0){
										percent_health = hp*100/max_hp;
									}
									printf("(%d%%), ", percent_health);
									if(percent_health > -1 && percent_health <= 25  && !hp_sound_played){
										hp_sound_played = true;
										PlaySound("low health.wav", NULL, SND_FILENAME|SND_ASYNC);
									}else{
										if(hp == 0 && !dead){
											dead=true;
											PlaySound("slain.wav", NULL, SND_FILENAME|SND_ASYNC);
										}
										if(percent_health > 25){
											hp_sound_played = false;
											dead=false;
										}
									}
								}
								ReadProcessMemory(hProcess,(LPVOID)mana_address,&mana,sizeof(int),0);
								if(game_started){
									if(mana > -1){
										printf("Mana=%d",mana);
									}

								}
								ReadProcessMemory(hProcess,(LPVOID)max_mana_address,&max_mana,sizeof(int),0);
								if(game_started){
									if(max_mana > -1){
										printf("/%d ",max_mana);
									}
									if(max_mana != 0){
										percent_mana = mana*100/max_mana;
									}
									printf("(%d%%), ", percent_mana);
									if(percent_mana > -1 && percent_mana <= 25 && !hp_sound_played && !mana_sound_played){
										PlaySound("low mana.wav", NULL, SND_FILENAME|SND_ASYNC);
										mana_sound_played = true;
									}else{
										if(percent_mana > 25){
											mana_sound_played = false;
										}
									}
								}
								gold=-1;
								ReadProcessMemory(hProcess,(LPVOID)gold_address,&gold,sizeof(int),0);
								if(game_started && gold > -1){
									printf("Gold=%d, ",gold);
								}
								if(gold < 0){
									gold=-1;
									break;
								}
								ReadProcessMemory(hProcess,(LPVOID)skill_point_address,&skill_points,sizeof(int),0);
								if(game_started){
									printf("Skill Points Available: %d\n", skill_points);
								}
								if(!game_started){
									printf("Game started\n");
									game_started = true;
								}
								gold=-1;
								Sleep(250);
							}
							if(gold<0 && game_started){
								printf("\nGame ended\n");
								break;
							}
						}
					}
					printf("Press any key to continue...");
					getch();
					return 0;
				}
			}
		}
		Sleep(2000);
	}
	getch();
}