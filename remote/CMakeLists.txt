CMAKE_MINIMUM_REQUIRED(VERSION 3.19)
PROJECT(remote)

SET (SAC2C_EXEC ./bin/sac2c CACHE STRING "A path to sac2c compiler")
SET (TARGETS seq seq_checks mt_pth CACHE STRING "Targets Set")

LIST(APPEND CMAKE_MODULE_PATH "${CMAKE_SOURCE_DIR}/cmake-common")
INCLUDE("${CMAKE_SOURCE_DIR}/cmake-common/UseSAC.cmake")

#  ADD_SAC_EXECUTABLE (inc-${t} inc.sac TARGET ${t})
foreach(t IN ITEMS ${TARGETS})
	ADD_SAC_EXECUTABLE (matmul-${t} matmul.sac TARGET ${t})
endforeach()
