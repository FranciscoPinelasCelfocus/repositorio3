pipeline {
	agent {
			dockerfile{
				//dir 'exercise'
				file Dockerfile
			}
		}
  	
  	options { 
		disableConcurrentBuilds()
	}


	environment {
		CONFIGS = '{																									\
			repositoryConfigs:[																									\
				{																									\
					name: "repository1",																									\
					urlWithoutProtocol: "github.com/FranciscoPinelasCelfocus/repositorio1",					\
					credentialId: "CREDENTIAL_ID_NB25023"					\
				},					\
				{					\
					name: "repository2",					\
					urlWithoutProtocol: "github.com/FranciscoPinelasCelfocus/repositorio2",					\
					credentialId": "CREDENTIAL_ID_NB25023"					\
				},					\
				{					\
					name: "repository3",					\
					urlWithoutProtocol: "github.com/FranciscoPinelasCelfocus/repositorio3",					\
					credentialId": "CREDENTIAL_ID_NB25023"					\
				}					\
			],					\
			mergeConfigs: [					\
				{					\
					sourceRepository: "repository1",					\
					targetRepository: "repository2",					\
					oneToOneMapping: "main:main",					\
					oneToManyMapping: "",					\
					manyToManyMapping: ""					\
				}					\
			]					\
		}'
		
		SEND_SUCCESS_EMAIL_TO = 'francisco.pinelas@celfocus.com'
		SEND_SUCCESS_EMAIL_SUBJECT = 'Automatic merge results report'
		SEND_SUCCESS_EMAIL_TEMPLATE_PATH = 'exercise/email-templates/success.html' 

		SEND_MAINTENANCE_EMAIL_TO = 'francisco.pinelas@celfocus.com'	
		SEND_MAINTENANCE_EMAIL_SUBJECT = 'Automatic merge results maintenance'
		SEND_MAINTENANCE_EMAIL_TEMPLATE_PATH = 'exercise/email-templates/maintenance.html' 
  	}

  	stages {
    	stage('Setup Remotes') {
      		steps { 
      			script {
					//TODO Store initial state in init branch, if not exists create refs/heads/init - use - show-ref --quiet
					sh "if git show-ref --quiet refs/heads/init; then git branch -D init; fi"
					sh "git checkout -b init"
					// TODO use readJSON to read CONFIGS to a local variable
					// for each repositoryConfig object call setupRemote method with defined parameters already implemented
					// use withCredentials to get password and user from jenkins
					def props = readJSON text: "$CONFIGS"
					props.repositoryConfigs.each { x ->
							//chamar metodo(x.credentialId) -> {githubUsername,githubPassword}
							withCredentials([[$class: 'UsernamePasswordMultiBinding',credentialsId: x.credentialId,usernameVariable: 'githubUsername',passwordVariable: 'githubPassword']])
							setupRemote(x.name,x.urlWithoutProtocol, env.githubUsername, env.githubPassword) 
					    }
      		}
    	}
		}
    	stage('Perform Merges') {
      		steps { 
      			script {
					def mergeReport = []
					
      			    // TODO use readJSON to read CONFIGS to a local variable
					// for each mergeConfig object assign oneToOneMapping to a variable and use convertOneToManyIntoOneToOneMapping 
					// and convertManyToManyIntoOneToOneMapping to convert the other JSON options to oneTOone, split the strings by " " like 
					// String1 + " " + String2 + " " + convertManyToManyIntoOneToOneMapping
					// call performMerges method with defined parameters already implemented and assign the return value to a variable like mergesPerformed
					// don´t forget to use replaceAll("  ", " ").trim() to avoid two spaces instead of one
					// Then check if mergesPerformed is not null and add it to mergeReport
					
					def props = readJSON text: "$CONFIGS"
					def result
					props.mergeConfigs.each { x ->
					
							result = x.oneToOneMapping + " " + 
							convertManyToManyIntoOneToOneMapping(x.targetRepository, x.oneToManyMapping) + " " + 
							convertManyToManyIntoOneToOneMapping(x.sourceRepository, x.manyToManyMapping)
							
							def mergesPerformed = performMerges(x.sourceRepository, x.targetRepository, result.replaceAll("  ", " ").trim())
							
							if(mergesPerformed != null){
								mergeReport.addAll(mergesPerformed)
							}
							
					    }
					
					sh "git checkout init"
					//TODO convert mergeReport using groovy.json.JsonOutput.toJson and write mergeReport to an json file
					
      			}
      		}
    	}
  	}
	/*post { 
        success { 
  			script {
			//TODO read mergeReport json file
			// call success email with report data
  			}
			// clean server
        	sh "git clean -d -fx . && git checkout -f init && git config --unset credential.helper"
        }
        unstable {
        	sh "git clean -d -fx . && git checkout -f init && git config --unset credential.helper"
			//TODO call maintenance email
           
        }
		failure {
			sh "git clean -d -fx . && git checkout -f init && git config --unset credential.helper"
		    //TODO call maintenance email
		}
    }*/
}


/*****************************************
* Send a Success email
****************************************/
def sendSuccessEmail(mergeReportData = '') {
	echo mergeReportData.toString()
	
	//TODO read html template file for success email with ENV variable already defined SEND_SUCCESS_EMAIL_TEMPLATE_PATH
	
	
	//TODO define and use 3 variables errorRowTemplateSpecs, successRowTemplateSpecs, noneRowTemplateSpecs to get the placeholders ROWS
	// use findEmailRowTemplate method with parameters
	
	boolean logErrors = errorRowTemplateSpecs != null
	boolean logSuccess = successRowTemplateSpecs != null
	boolean logNone = noneRowTemplateSpecs != null

	if (!logErrors && !logSuccess && !logNone) {
		emailext 	subject: "$SEND_SUCCESS_EMAIL_SUBJECT", 
    				to: "$SEND_SUCCESS_EMAIL_TO",
    				body: emailTemplate
    	return;
	}

	def errorRowsHTML = ""<<""
	def successRowsHTML = ""<<""
	def noneRowsHTML = ""<<""
	
	if (mergeReportData != null) {
		//TODO read json configs
		// for each mergeReportData.toArray() if
		// rowData "result" = ERROR update errorRowsHTML with the result of fillDataInHTMLRow method wit correct parameters
		// rowData "result" = SUCCESS update successRowsHTML with the result of fillDataInHTMLRow method wit correct parameters
		// rowData "result" = NONE update noneRowsHTML with the result of fillDataInHTMLRow method wit correct parameters
		
		
		
		def configs = readJSON text: "$CONFIGS"
		mergeReportData.toArray().each { rowData ->
			if (rowData.getString("result") == "ERROR" && logErrors) {
				errorRowsHTML <<=  fillDataInHTMLRow(errorRowTemplateSpecs.rowTemplate, rowData, configs.repositoryConfigs)
			}
			else if (rowData.getString("result") == "SUCCESS" && logSuccess) {
				successRowsHTML <<=  fillDataInHTMLRow(successRowTemplateSpecs.rowTemplate, rowData, configs.repositoryConfigs)
			}
			else if (rowData.getString("result") == "NONE" && logNone) {
				noneRowsHTML <<=  fillDataInHTMLRow(noneRowTemplateSpecs.rowTemplate, rowData, configs.repositoryConfigs)
			}
		}
	}
	
	//TODO create and fill in a variable emailBody with returned values of fillEmailRows method for errorRowsHTML, successRowsHTML and noneRowsHTML
	
	emailext subject: "$SEND_SUCCESS_EMAIL_SUBJECT", 
			 to: "$SEND_SUCCESS_EMAIL_TO",
			 body: emailBody
}

/*****************************************
* Injects data in a HTML row template  
****************************************/
def fillDataInHTMLRow(rowTemplate = '', rowData = '', repositoryConfigs = [ ]) {
	def sourceRepository = rowData.getString("sourceRepository")
	def sourceBranch = rowData.getString("sourceBranch")
	
	def targetRepository = rowData.getString("targetRepository")
	def targetBranch = rowData.getString("targetBranch")

	def lastIndexOfSlashInSourceBranch = sourceBranch.lastIndexOf("/")
	lastIndexOfSlashInSourceBranch = lastIndexOfSlashInSourceBranch != -1 ? lastIndexOfSlashInSourceBranch + 1 : 0 
	
	def lastIndexOfSlashInTargetBranch = targetBranch.lastIndexOf("/")
	lastIndexOfSlashInTargetBranch = lastIndexOfSlashInTargetBranch != -1 ? lastIndexOfSlashInTargetBranch + 1 : 0 
	
	return   rowTemplate.replaceAll("PLACEHOLDER_ROW_SOURCE_REPO_NAME", sourceRepository)
						.replaceAll("PLACEHOLDER_ROW_SOURCE_BRANCH_PATH", sourceBranch)
						.replaceAll("PLACEHOLDER_ROW_SOURCE_BRANCH_NAME", sourceBranch.substring(lastIndexOfSlashInSourceBranch))
						.replaceAll("PLACEHOLDER_ROW_SOURCE_BRANCH_URL", makeBranchURL(sourceRepository, sourceBranch, repositoryConfigs))
						.replaceAll("PLACEHOLDER_ROW_TARGET_REPO_NAME", targetRepository)
						.replaceAll("PLACEHOLDER_ROW_TARGET_BRANCH_PATH", targetBranch)
						.replaceAll("PLACEHOLDER_ROW_TARGET_BRANCH_NAME", targetBranch.substring(lastIndexOfSlashInTargetBranch))
						.replaceAll("PLACEHOLDER_ROW_TARGET_BRANCH_URL", makeBranchURL(targetRepository, targetBranch, repositoryConfigs))
						.replaceAll("PLACEHOLDER_ROW_TARGET_BRANCH_LAST_COMMITTER", rowData.getString("lastCommitterBeforeMerge"))
}

def makeBranchURL(repositoryName = '', branchPath = '', repositoryConfigs = [ ]) {
	def repositoryConfig = repositoryConfigs.find { it.name == repositoryName }
	return "https://" + repositoryConfig.urlWithoutProtocol + "/tree/" + branchPath
}

/*****************************************
* Replaces in the email body the rows template
* placeholder with the rows HTML provided as input  
****************************************/
def fillEmailRows(performFill = false, emailBody = '', rowTemplateSpecs = '', rowsHTML = '') {
	if (performFill != true) {
		return emailBody
	}
	return emailBody.replaceAll(rowTemplateSpecs.rowsPlaceholder, rowsHTML)
}

/*****************************************
* Searched in the email template for a 
* specific row template delimmited by the 
* placeholder provided as input
****************************************/
def findEmailRowTemplate(emailTemplate = '', placeholder = '') {
	if (emailTemplate == null || placeholder == null) {
		return null
	}
	
	def indexOfPlaceholderStart = emailTemplate.indexOf(placeholder + "_START")
	def indexOfPlaceholderEnd = emailTemplate.indexOf(placeholder + "_END")
	
	if (indexOfPlaceholderStart == -1 || indexOfPlaceholderEnd == -1) {
		return null
	}
	
	def placeholderStartLength = (placeholder + "_START").length()
	def placeholderEndLength = (placeholder + "_END").length()
	return [
		rowsPlaceholder : emailTemplate.substring(indexOfPlaceholderStart, indexOfPlaceholderEnd + placeholderEndLength),
		rowTemplate : emailTemplate.substring(indexOfPlaceholderStart + placeholderStartLength, indexOfPlaceholderEnd)
	]
}

/*****************************************
* Send a MAINTENANCE email
****************************************/
def sendMaintenanceEmail() {
    emailext 	subject: "$SEND_MAINTENANCE_EMAIL_SUBJECT", 
    			to: "$SEND_MAINTENANCE_EMAIL_TO",
    			body: readFile("$SEND_MAINTENANCE_EMAIL_TEMPLATE_PATH")
}



/*****************************************
* Add repo remote to workspace and 
* perform git fetch
****************************************/
def setupRemote(name = '', urlWithoutProtocol = '', username = '', password = '') {
	boolean remoteExists = (sh(returnStdout: true, script: 'if [[ $(git remote | grep ^' + name + '$) ]]; then echo "true"; else echo "false"; fi').trim() == "true")
	
	if (remoteExists) {
		//Set remote url (to be sure)
		sh "git remote set-url " + name + " https://" + urlWithoutProtocol
	}
	else {
		//Create remote
		sh "git remote add " + name + " https://" + urlWithoutProtocol
	}

	sh "echo 'https://" + java.net.URLEncoder.encode(username, "UTF-8") + ":" + java.net.URLEncoder.encode(password, "UTF-8") + "@"+ urlWithoutProtocol + "' >> '$WORKSPACE/.git/.git-credentials'"
	sh "git config credential.helper \"store --file='$WORKSPACE/.git/.git-credentials'\""

	// remove all local tags & fetch remote tags
	sh "git tag -l | xargs git tag -d && git fetch -t"
	//Fetch remote
	sh "git fetch -f -P -p " + name
}

/*****************************************
* Convert the pattern mapping to 
* a direct branch map config
****************************************/
def convertOneToManyIntoOneToOneMapping(targetRepository = '', oneToManyMapping = '') {
	if (oneToManyMapping == null || oneToManyMapping.trim() == "") {
		return ""
	}
	
	def oneToOneMapping = ""<<""
	def oneToManyMappingList = oneToManyMapping.trim().split(' ')

    oneToManyMappingList.each { oneToManyMappingItem ->
		if (oneToManyMappingItem.contains(":")) {
			def oneToManyMappingItemConfig = oneToManyMappingItem.split(':')
			def sourceBranch = oneToManyMappingItemConfig[0]
			def targetPattern = oneToManyMappingItemConfig[1]
			
			def newOneToOneMapping = sh(returnStdout: true, script: "git branch -r | \
																	 grep $targetRepository/$targetPattern | \
																	 sed -e 's@^  $targetRepository/@@g' | \
																	 xargs -I {} echo $sourceBranch:{}")

			newOneToOneMapping = newOneToOneMapping.replaceAll("\n"," ").trim()
			oneToOneMapping <<= newOneToOneMapping
		}
	}
	
	return oneToOneMapping.toString()
}

/*****************************************
* Convert the pattern mapping to 
* a direct branch map config
****************************************/
def convertManyToManyIntoOneToOneMapping(sourceRepository = '', manyToManyMapping = '') {
	if (manyToManyMapping == null || manyToManyMapping.trim() == "") {
		return ""
	}
	
	def oneToOneMapping = ""<<""
	def manyToManyMappingList = manyToManyMapping.trim().split(' ')

    manyToManyMappingList.each { manyToManyMappingItem ->
		if (manyToManyMappingItem.contains(":")) {
			def manyToManyMappingItemConfig = manyToManyMappingItem.split(':')
			def sourcePattern = manyToManyMappingItemConfig[0]
			def targetPattern = manyToManyMappingItemConfig[1]
			
			def newOneToOneMapping = sh(returnStdout: true, script: "git branch -r | \
																	 grep $sourceRepository/$sourcePattern | \
																	 sed -e 's@^  $sourceRepository/@@g' | \
																	 xargs -I {} echo {}:{} | \
																	 sed -e 's@:${sourcePattern}@:${targetPattern}@g'")

			newOneToOneMapping = newOneToOneMapping.replaceAll("\n"," ").trim()
			oneToOneMapping <<= newOneToOneMapping
		}
	}

	return oneToOneMapping.toString()
}

/*****************************************
* Merge the branches based in a direct 
* mapping between source and target
****************************************/
def performMerges(sourceRepository = '', targetRepository = '', oneToOneMapping = '') {
	if (oneToOneMapping == null || oneToOneMapping.trim() == "") {
		return
	}
	
	//TODO trim oneToOneMapping variable by space ' ' and assign it to a variable  
	def oneToOneMappingList = oneToOneMapping.trim().split(' ')
	def mergeReport = []	
	
	// TODO for each one to one mapping check if cointains ":", if so split it to get the source branch and the target branch
	// Then call mergeBranches with the requested parameters
	// Analyse mergeBranches
	
	oneToOneMappingList.each { oneToOneMappingBranch ->
		if (oneToOneMappingBranch.contains(":")) {
			def oneToOneMappingBranches = oneToOneMappingBranch.split(':')
			def sourceBranch = oneToOneMappingBranches[0]
			def targetBranch = oneToOneMappingBranches[1]
			
			mergeReport.add(mergeBranches(sourceRepository, sourceBranch, targetRepository, targetBranch))
		}
	}
	
	
	
        
    return mergeReport
}

/*****************************************
* To use this function to merge the 
* legacy branch into the new branch
* Both provided as input
****************************************/
def mergeBranches(sourceRepository = '', sourceBranch = '', targetRepository = '', targetBranch = '') {
	echo "##### Merging '$sourceBranch' from '$sourceRepository' into '$targetBranch' from '$targetRepository' #####"

	//Switch to init branch to enable reset of "local-legacy" and "local-origin"
	sh "git clean -d -fx . && git checkout -f init"
	
	//Remove "local-legacy" and "local-origin" braches if they exist
	sh "if git show-ref --quiet refs/heads/local-legacy; then git branch -D local-legacy; fi"
	sh "if git show-ref --quiet refs/heads/local-origin; then git branch -D local-origin; fi"
	
	//Checkout $sourceBranch (it should always exist) into "local-legacy"
	sh "git checkout -b local-legacy $sourceRepository/$sourceBranch"
	
	//Hash of commit in source branch
	def headCommitSourceBranch = sh(returnStdout: true, script: "echo \$(git log --pretty=format:'%H' -n 1)").trim()
	
	//Get baseline from source if branch doesn't exist in target
	boolean isNewBranchInTarget = sh(returnStdout: true, script: "git branch -r | egrep '$targetRepository/$targetBranch\$' || echo ''").trim().isEmpty()
	if (isNewBranchInTarget) {
		sh "git checkout -b local-origin $sourceRepository/$sourceBranch"
	}
	else {
		sh "git checkout -b local-origin $targetRepository/$targetBranch"
	}
		
	//Store hash of commit before merge	
	def headCommitBeforeMerge = sh(returnStdout: true, script: "echo \$(git log --pretty=format:'%H' -n 1)").trim()
	def headCommitAuthorBeforeMerge = sh(returnStdout: true, script: "echo \$(git show --format=\"%aN\" \"$headCommitBeforeMerge\" | awk 'NR == 1')").trim()
	
	//Perform merge
	sh "git merge --ff local-legacy --allow-unrelated-histories -m \"Merge branch '$sourceBranch' into '$targetBranch'\" || true"

	//Hash of commit after merge
	def headCommitAfterMerge = sh(returnStdout: true, script: "echo \$(git log --pretty=format:'%H' -n 1)").trim()
	
	//Find common anchestor to identify if there was merge conflicts
	def commonAncestor = sh(returnStdout: true, script: "echo \$(git merge-base local-legacy local-origin)").trim()

	//Prepare report item
	def mergeReportItem = [
	    sourceRepository : sourceRepository,
	    sourceBranch : sourceBranch,
	    targetRepository : targetRepository,
	    targetBranch : targetBranch,
	    lastCommitterBeforeMerge : headCommitAuthorBeforeMerge
	]

	if (isNewBranchInTarget || headCommitBeforeMerge != headCommitAfterMerge) {
		sh "git push $targetRepository HEAD:$targetBranch"
		mergeReportItem.result = "SUCCESS"
    }
    else if (commonAncestor != headCommitSourceBranch) {
		sh "git reset --merge"
		mergeReportItem.result = "ERROR"
    }
    else {
	    mergeReportItem.result = "NONE"
    }
	return mergeReportItem
}