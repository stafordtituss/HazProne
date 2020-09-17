#!/usr/bin/env python3

import sys
import os
import re
import texts
import shutil
import datetime
import subprocess
from python_terraform import *
from functions import (
    gen_whitelist
)

# Global Variables------------------------------------------------------------------------------------
opr = ""
quest_id = ""
user_prof = ""
ip_addr = ""
quest_folder = ""
quest_folder_final = ""
quest_game_env = ""
quest_game_env_del = ""

dt = datetime.datetime.now()

day = dt.strftime("%d")
month = dt.strftime("%b")
year = dt.strftime("%Y")
hour = dt.strftime("%I")
minute = dt.strftime("%M")
seconds = dt.strftime("%S")
time = dt.strftime("%p")

rand = f'{day}-{month}-{year}-{hour}-{minute}-{seconds}-{time}'

# Beginning of Functions-----------------------------------------------------

if sys.argv[1].casefold() == "help":
    print(texts.HAZPRONE)
    sys.exit()
elif sys.argv[1].casefold() == "quest":
    if len(sys.argv) == 3:
        if sys.argv[2].casefold() == "q1-openworld":
            print(texts.OPENWORLD)
            sys.exit()
        elif sys.argv[2].casefold() == "q2-up":
            print(texts.UP)
            sys.exit()
        elif sys.argv[2].casefold() == "q3-infiltrate":
            print(texts.INFILTRATE)
            sys.exit()
        elif sys.argv[2].casefold() == "q4-finals":
            print(texts.FINALS)
            sys.exit()
        else:
            print(texts.QUESTS)
            sys.exit()
    else:
        print(texts.QUESTS)
        sys.exit()
elif len(sys.argv) < 4:
    print("Atleast Three Arguments are required!!")
    sys.exit()
elif len(sys.argv) > 4:
    print("Only Three arguments are required!!")
    sys.exit()
else:
    operation = sys.argv[1].lower()
    quest = sys.argv[2].lower()
    profile = sys.argv[3].lower()
    print('''
    *******************************************
    ===========================================
    
            Initializing HAZPRONE!!!
    
    +++++++++++++++++++++++++++++++++++++++++++
    ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
    ''')
    if operation != "start" and operation != "stop":
        print("Operation must be either start or stop only!!")
        sys.exit()
    elif quest != "q1-openworld" and quest != "q2-up" and quest != "q3-infiltrate" and quest != "q4-finals":
        print(texts.QUESTS_WRONG)
        sys.exit()
    else:
        profile_check = subprocess.Popen(["aws", "--profile", profile, "sts", "get-caller-identity"], stdout=subprocess.PIPE, stderr=subprocess.PIPE)
        profile_check.wait()
        profile_out = profile_check.stdout.read().decode("utf-8").strip()
        profile_err = profile_check.stderr.read().decode("utf-8").strip()
        if profile_err:
            print(profile_err)
            print("\n HAZPRONE :: Enter the correct Profile name!!\n")
            sys.exit()
        else:
            print(f'\nProfile {profile} is Valid!!\n')
    if operation == "stop":
        print("\nHAZPRONE :: Enter yes to confirm stopping the quest!!!\n")
        stop_op = input("Your Entry : ")
        if stop_op.casefold() != "yes":
            print("\nQuiting Hazprone!!!\n")
            sys.exit()
        else:
            opr = "stop"
            quest_id = quest
            user_prof = profile

    elif operation == "start":
        print("Checking for whitelist.txt!!\n")
        if not os.path.exists("./whitelist.txt"):
            print('''
HAZPRONE :: whitelist.txt file does not exist. Hazprone will
            create a new file by curling your public ip from
            ifconfig.me if you type yes. If you would rather 
            configure the file on your own type no to exit the 
            framework.\n
                ''')
            whitelist_conf_1 = input("Your Entry : ")
            if whitelist_conf_1 == "yes":
                print("\nHAZPRONE :: Generating new whitelist.txt file!\n")
                ip = gen_whitelist()
                print("Your IP Address is: "+ip)
                if not ip:
                    print("\nHAZPRONE :: Unknown Error! Manually add IP to whitelist.txt!")
                    sys.exit()
                if not re.findall(r".*\/(\d+)", ip):
                    ip = ip.split("/")[0] + "/32"
                    with open("./whitelist.txt", "w") as ip_file:
                        ip_file.write(ip)
                        print("Written Succesfully")
                
            else:
                print("\nHAZPRONE :: Quiting Hazprone!\n")
                sys.exit()
        else:
            print('''
HAZPRONE :: whitelist.txt file exists! Type yes if you would like 
            Hazprone to curl your IP Adress from ifconfig.me and 
            overwrite the existing whitelist.txt file, otherwise 
            type no to continue with existing file.\n
            ''')
            whitelist_conf = input("Your Entry : ")
            if whitelist_conf == "yes":
                print("\nHAZPRONE :: Generating new whitelist.txt file!\n")
                ip = gen_whitelist()
                print("Your IP Adress is: "+ip)
                if not ip:
                    print("\nHAZPRONE :: Unknown Error! Manually add IP to whitelist.txt!")
                    sys.exit()
                if not re.findall(r".*\/(\d+)", ip):
                    ip = ip.split("/")[0] + "/32"
                    with open("./whitelist.txt", "w") as ip_file:
                        ip_file.write(ip)
                        print("Written Succesfully")
            else:
                print("\nHAZPRONE :: Continuing with existing whitelist.txt file!\n")
                with open("./whitelist.txt", "r") as ip_file:
                    ip = ip_file.read()
                    print(ip)
        print("\nHAZPRONE :: Enter yes to confirm starting the quest!!\n")
        start_op = input("Your Entry : ")
        if start_op.casefold() != "yes":
            print("\nQuiting Hazprone!!!\n")
            sys.exit()
        else:
            opr = "start"
            quest_id = quest
            user_prof = profile
            ip_addr = ip

print("The operation is : "+opr)
print("The quest is : "+quest_id)
print("The profile is : "+user_prof)
print("The ip address is : "+ip_addr)
    
if quest_id == "q1-openworld":
    quest_folder = "./Quests/q1-openworld/terraform"
    quest_game_env = f'./q1-openworld-env-{rand}'
elif quest_id == "q2-up":
    quest_folder = "./Quests/q2-up/terraform"
    quest_game_env = f'./q2-up-env-{rand}'
elif quest_id == "q3-infiltrate":
    quest_folder = "./Quests/q3-infiltrate/terraform"
    quest_game_env = f'./q3-infiltrate-env-{rand}'
elif quest_id == "q4-finals":
    quest_folder = "./Quests/q4-finals/terraform"
    quest_game_env = f'./q4-finals-env-{rand}'
else:
    print("\nHAZPRONE :: Internal Error! Please try again!!\n")
    sys.exit()

region = "us-east-1"
tf = Terraform(working_dir=f'{quest_game_env}/terraform')
if opr == "start" and user_prof:
    if os.path.isfile("./hazprone_state.txt") and os.path.exists("./hazprone_state.txt"):
        state_file_check = open("hazprone_state.txt", "r")
    else:
        print('''
    HAZPRONE :: Hazprone's state file is missing!!! Please create a
    hazprone_state.txt file in the directory where Hazprone's main 
    files are present.\n
            ''')
        sys.exit()
    quest_game_env_del = state_file_check.readline()
    state_file_check.close()
    if quest_game_env_del != "":
        print('''
    HAZPRONE :: The hazprone state file is not empty!! Either a Quest has 
                already been started or some Internal Error has occured.
                If a Quest is currently running, please stop it, inorder to
                start another quest!\n
              ''')
        sys.exit()
    if not os.path.exists(quest_game_env):
        print("\nHAZPRONE :: Initializing Quest Environment!!\n")
        src = quest_folder.replace('/terraform', '')
        dest = quest_game_env 
        print("\nHAZPRONE :: Copying files!\n")
        quest_folder_final = shutil.copytree(src, dest)
        if os.path.exists(f'{quest_game_env}/terraform/start.sh'):
            start_process = subprocess.Popen(["sh", "start.sh"], cwd=f'{quest_game_env}/terraform')
            start_process.wait()
        else:
            print("\nCLOUDPRONE :: No intermediate start script! Directly starting the Quest!\n")
        print("\nHAZPRONE :: Quest Environment is ready!!\n")
    elif os.path.exists(quest_game_env):
        print("\nHAZPRONE :: Quest Folder already exists!! First Destroy it to start another Session!\n")
        print("\nCLOUPRONE :: You could manually remove the folder if nothing else works!!\n")
        sys.exit()
    if not os.path.exists(quest_game_env):
        print("\nHAZPRONE :: There has been an error in creating Quest folder. Make sure Hazprone has all the required permissions!\n")
    return_code, stdout, stderr = tf.init(capture_output=False)
    return_code, stdout, stderr = tf.plan(capture_output=False, var={'profile': user_prof, 'region': region, 'userIP': ip_addr})
    return_code, stdout, stderr = tf.apply(capture_output=False, var={'profile': user_prof, 'region': region, 'userIP': ip_addr})
    if return_code != 0:
        print("\n HAZPRONE :: Error Code returned by Terraform. Please try again!!\n")
        if not os.path.exists("./trash"):
            os.makedirs("./trash")
            print("\nHAZPRONE :: Deleting Quest Folder!!\n")
            shutil.move(quest_game_env, './trash')
        elif os.path.exists("./trash"):
            print("\nHAZPRONE :: Deleting Quest Folder!!\n")
            shutil.move(quest_game_env, './trash')
        else:
            print("\nHAZPRONE :: Fatal Internal Error has Occured!!\n")
        sys.exit()
    else:
        state_file = open("hazprone_state.txt", "w")
        n = state_file.write(quest_game_env)
        state_file.close()
        print(f'\nHAZPRONE QUEST {quest_id} HAS BEEN INITIATED!!!\n')
        sys.exit()
elif opr == "stop" and user_prof:
    if os.path.isfile("./hazprone_state.txt") and os.path.exists("./hazprone_state.txt"):
        state_file = open("hazprone_state.txt", "r")
    else:
        print('''
    HAZPRONE :: Hazprone's state file is missing!!! Please create a
    hazprone_state.txt file in the directory where Hazprone's main 
    files are present.\n
            ''')
    quest_game_env_del = state_file.readline()
    if quest_game_env_del == "":
        print('''
    HAZPRONE :: The hazprone state file is empty!! Either no Quest has been started or 
                an Internal Error has occured. If resources have been deployed please 
                delete them manually!!\n
              ''')
        sys.exit()
    state_file.close()
    tf = Terraform(working_dir=f'{quest_game_env_del}/terraform')
    if not os.path.exists(quest_game_env_del):
        print('''
    HAZPRONE :: Internal Error!! The Quest folder can't be found!! 
                Manually destroy the AWS Resources and move the 
                quest folder to ./trash\n
        ''')
        sys.exit()
    return_code, stdout, stderr = tf.destroy(capture_output=False, var={'profile': user_prof, 'region': region, 'userIP': ip_addr})
    if return_code != 0:
        print("\nHAZPRONE :: Terraform has returned an Error Code. Please try again or manually destroy the resource!\n")
        sys.exit()
    else:
        open("hazprone_state.txt", "w").close()
        if os.path.exists(quest_game_env_del) and os.path.isdir(quest_game_env_del):
            if not os.path.exists("./trash"):
                os.makedirs("./trash")
                print("\nHAZPRONE :: Deleting Quest Folder!!\n")
                shutil.move(quest_game_env_del, './trash')
            elif os.path.exists("./trash"):
                print("\nHAZPRONE :: Deleting Quest Folder!!\n")
                shutil.move(quest_game_env_del, './trash')
            else:
                print("\nHAZPRONE :: Fatal Internal Error has Occured!!\n")
                sys.exit()
        else:
            print("\nHAZPRONE :: Quest Folder does not Exist!! Please delete the resources manually!\n")

        print(f'\nHAZPRONE QUEST {quest_id} HAS BEEN TERMINATED!!!\n')
        sys.exit()
else:
    print("\nHAZPRONE :: Unknow Error has occurred!!! Please retry!!\n")
    sys.exit()

# The End-------------------------------------------------------------------------------