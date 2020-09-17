HAZPRONE = '''
    HazProne is a Cloud Pentesting Framework that emulates close to 
    Real-World Scearios by deploying Vulnerable-By-Demand aws resources
    enabling you to pentest Vulnerabilities within, and hence, gain 
    a better understanding of what could go wrong and why!!

    USAGE: Hazprone <operation> <quest> <profile>

        operation : This argument is required to either start or stop
                    the quest.
                    
                    OPTIONS:
                    []    start
                    []    stop 

        quest     : This argument is required to identify the quest
                    you wish to start or stop.
                    
                    OPTIONS:
                    []    q1-openworld
                    []    q2-up
                    []    q3-infiltrate
                    []    q4-finals

        profile   : This argument is required to use the profile
                    configured using the aws cli tool. 

    You could also get detailed information on the Quests by 
    following the syntax given below:

        Hazprone quest <quest-name>

            <quest-name> : [] q1-openworld
                           [] q2-up
                           [] q3-infiltrate 
                           [] q4-finals

    '''

OPENWORLD = '''
    QUEST 1 - openworld :
    ==================================================================

        The openworld quest is the first quest in version 0.1.0 
        of Hazprone. On starting this quest you are provided 
        access-key-id and secret-key of a user nikolas, using which 
        you must get the top-secret file stored in a private 
        S3 bucket.
        
    ==================================================================
            '''

UP = '''
    QUEST 2 - up :
    ==================================================================

        The up quest is the second quest in version 0.1.0 
        of Hazprone. On starting this quest you are provided 
        access-key-id and secret-key of two users, weaver and
        starker, using which you must try to escalate your 
        privileges to get an administrator account.

    ===================================================================
    '''

INFILTRATE = '''
    QUEST 3 - infiltrate :
    ===================================================================

        The infiltrate quest is the third quest in version 
        0.1.0 of Hazprone. On starting this quest you are 
        provided the public ip of a website where you must
        try to access the secret file stored within a private
        EC2 Instance.

    ===================================================================
            '''

FINALS = '''
    QUEST 4 - finals :
    ===================================================================

        The finals quest is the fourth quest in version 
        0.1.0 of Hazprone. On starting this quest you are 
        provided the public ip of a website where you must
        try to access the secret flag stored within a dynamodb
        table.

    ===================================================================
            '''
    
QUESTS = '''
    Include any one of the following quests to know more about it!
        OPTIONS:
            [] q1-openworld
            [] q2-up
            [] q3-infiltrate
            [] q4-finals
        '''

QUESTS_WRONG = '''
    Quest must be any one of the following!
        OPTIONS:
            [] q1-openworld
            [] q2-up
            [] q3-infiltrate
            [] q4-finals
            '''

