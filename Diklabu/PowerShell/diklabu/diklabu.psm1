﻿Import-Module diklabumanger.psm1
Import-Module diklabu_schueler.psm1
Import-Module diklabu_klassen.psm1
Import-Module diklabu_betriebe.psm1
Import-Module diklabu_ausbilder.psm1
Import-Module diklabu_coursemember.psm1
Import-Module diklabu_kurswahl.psm1
Import-Module diklabu_lehrer.psm1
Import-Module diklabu_poll.psm1
Import-Module diklabu_bbsplanung.psm1
Import-Module diklabu-seafile.psm1
Import-Module diklabu_moodle.psm1
Import-Module diklabu_ldap.psm1

Export-ModuleMember -Function Set-Diklabuserver
Export-ModuleMember -Function Get-Diklabuserver
Export-ModuleMember -Function Login-Diklabu
Export-ModuleMember -Function Add-Coursemember
Export-ModuleMember -Function Find-Coursemember
Export-ModuleMember -Function Remove-Coursemember
Export-ModuleMember -Function Get-Coursemember
Export-ModuleMember -Function Get-Coursemembership
Export-ModuleMember -Function Find-Pupil
Export-ModuleMember -Function Get-Pupil
Export-ModuleMember -Function Set-Pupil
Export-ModuleMember -Function New-Pupil
Export-ModuleMember -Function Delete-Pupil
Export-ModuleMember -Function Find-Course
Export-ModuleMember -Function Get-Course
Export-ModuleMember -Function Set-Course
Export-ModuleMember -Function New-Course
Export-ModuleMember -Function Delete-Course

Export-ModuleMember -Function Find-Company
Export-ModuleMember -Function Get-Company
Export-ModuleMember -Function Set-Company
Export-ModuleMember -Function New-Company
Export-ModuleMember -Function Delete-Company

Export-ModuleMember -Function Find-Instructor
Export-ModuleMember -Function Get-Instructor
Export-ModuleMember -Function Set-Instructor
Export-ModuleMember -Function New-Instructor
Export-ModuleMember -Function Delete-Instructor

Export-ModuleMember -Function Add-Coursevoting
Export-ModuleMember -Function Remove-Coursevoting
Export-ModuleMember -Function Enable-Coursevoting
Export-ModuleMember -Function Disable-Coursevoting
Export-ModuleMember -Function Reset-Coursevoting
Export-ModuleMember -Function Clear-Coursevoting
Export-ModuleMember -Function Get-Coursevoting
Export-ModuleMember -Function Get-Coursevotings
Export-ModuleMember -Function New-Coursevoting
Export-ModuleMember -Function Stop-Coursevoting

Export-ModuleMember -Function Get-Teacher
Export-ModuleMember -Function Get-Teachers
Export-ModuleMember -Function Set-Teacher
Export-ModuleMember -Function New-Teacher
Export-ModuleMember -Function Delete-Teacher

Export-ModuleMember -Function Get-Polls
Export-ModuleMember -Function Get-Poll
Export-ModuleMember -Function Get-Pollresults
Export-ModuleMember -Function New-PollQuestion
Export-ModuleMember -Function Set-PollQuestion
Export-ModuleMember -Function Delete-PollQuestion
Export-ModuleMember -Function Get-PollQuestion
Export-ModuleMember -Function Get-PollQuestions
Export-ModuleMember -Function New-PollAnswer
Export-ModuleMember -Function Set-PollAnswer
Export-ModuleMember -Function Delete-PollAnswer
Export-ModuleMember -Function Get-PollAnswer
Export-ModuleMember -Function Get-PollAnswers
Export-ModuleMember -Function Add-PollAnswer
Export-ModuleMember -Function Remove-PollAnswer
Export-ModuleMember -Function New-Poll
Export-ModuleMember -Function Set-Poll
Export-ModuleMember -Function Delete-Poll
Export-ModuleMember -Function Add-PollQuestion
Export-ModuleMember -Function Remove-PollQuestion
Export-ModuleMember -Function New-PollSubscriber
Export-ModuleMember -Function Get-PollSubscribers
Export-ModuleMember -Function Delete-PollSubscriber
Export-ModuleMember -Function Invite-PollSubscriber
Export-ModuleMember -Function Search-Pupil
Export-ModuleMember -Function Get-Pupils
Export-ModuleMember -Function Get-Companies
Export-ModuleMember -Function Get-Instructor

Export-ModuleMember -Function Connect-BbsPlan
Export-ModuleMember -Function Disconnect-BbsPlan
Export-ModuleMember -Function Test-BPCoursemember
Export-ModuleMember -Function Get-BPPupils
Export-ModuleMember -Function Get-BPCompanies
Export-ModuleMember -Function Get-BPCompany
Export-ModuleMember -Function Get-BPInstructors
Export-ModuleMember -Function Get-BPTeachers
Export-ModuleMember -Function Get-BPCourses
Export-ModuleMember -Function Get-BPCoursemember
Export-ModuleMember -Function Export-BBSPlanung

Export-ModuleMember -Function Login-Seafile
Export-ModuleMember -Function New-SFGroup
Export-ModuleMember -Function Get-SFGroups
Export-ModuleMember -Function Delete-SFGroup
Export-ModuleMember -Function Add-SFGroupmember
Export-ModuleMember -Function Remove-SFGroupmember
Export-ModuleMember -Function Get-SFGroupmember
Export-ModuleMember -Function New-SFUser
Export-ModuleMember -Function Delete-SFUser
Export-ModuleMember -Function Get-SFUsers
Export-ModuleMember -Function Get-SFUser

Export-ModuleMember -Function Login-Moodle
Export-ModuleMember -Function Get-MoodleCourses
Export-ModuleMember -Function Get-MoodleCategories
Export-ModuleMember -Function Get-MoodleCohorts
Export-ModuleMember -Function Get-MoodleCoursemember
Export-ModuleMember -Function Get-MoodleUser
Export-ModuleMember -Function New-MoodleCourse
Export-ModuleMember -Function Copy-MoodleCourse
Export-ModuleMember -Function Delete-MoodleCourse
Export-ModuleMember -Function Add-MoodleCourseMember
Export-ModuleMember -Function Remove-MoodleCourseMember
Export-ModuleMember -Function Get-MoodleCohortMember

Export-ModuleMember -Function Login-LDAP
Export-ModuleMember -Function Get-LDAPTeachers
Export-ModuleMember -Function Get-LDAPTeacher
Export-ModuleMember -Function Get-LDAPCourses
Export-ModuleMember -Function Get-LDAPCourse
Export-ModuleMember -Function Get-LDAPCourseMember
