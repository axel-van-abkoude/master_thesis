CMAKE_MINIMUM_REQUIRED(VERSION 3.19)
PROJECT(remote)
LIST(APPEND CMAKE_MODULE_PATH "${CMAKE_SOURCE_DIR}/cmake-common")
FIND_PACKAGE(SAC REQUIRED)
INCLUDE("${CMAKE_SOURCE_DIR}/cmake-common/UseSAC.cmake")

SET (TARGETS seq seq_checks mt_pth CACHE STRING "Targets Set")

foreach(t IN ITEMS ${TARGETS})
	ADD_SAC_EXECUTABLE (inc-${t} inc.sac TARGET ${t})
	ADD_SAC_EXECUTABLE (matmul-${t} matmul.sac TARGET ${t})
endforeach()
