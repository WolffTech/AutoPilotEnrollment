sc config DellOptimizer start=disabled
Taskkill.exe /IM DellOptimizer.exe /F /T
DellOptimizer.exe /remove /silent
sc delete dellOptimizer