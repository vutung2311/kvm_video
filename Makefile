export LC_ALL=C
SHELL:=/bin/bash

CURRENT_DIR := $(shell pwd)
ifndef LUCKFOX_SDK_PATH
$(error Please Set Luckfox-pico SDK Path. Such as: export LUCKFOX_SDK_PATH=/home/user/luckfox-pico)
endif
RK_SDK_BASE ?= $(LUCKFOX_SDK_PATH)
RK_APP_CROSS := $(RK_SDK_BASE)/tools/linux/toolchain/arm-rockchip830-linux-uclibcgnueabihf/bin/arm-rockchip830-linux-uclibcgnueabihf
RK_MEDIA_OUTPUT := $(RK_SDK_BASE)/media/out
RK_MEDIA_INCLUDE_PATH := $(RK_MEDIA_OUTPUT)/include
RK_APP_MEDIA_LIBS_PATH :=  $(RK_MEDIA_OUTPUT)/lib

RK_APP_LDFLAGS = -L $(RK_APP_MEDIA_LIBS_PATH) -lpthread -lrockit -lrockchip_mpp  -lrga

CC = $(RK_APP_CROSS)-gcc
CXX = $(RK_APP_CROSS)-g++

INCLUDES = -I $(CURRENT_DIR) -I $(CURRENT_DIR)/npu/include -I $(CURRENT_DIR)/osd -I $(CURRENT_DIR)/include/rknn -I $(CURRENT_DIR)/include/opencv4 -I $(CURRENT_DIR)/librga/include -I $(CURRENT_DIR)/librga/samples/utils/allocator/include -I $(RK_MEDIA_INCLUDE_PATH) -I $(RK_MEDIA_INCLUDE_PATH)/libdrm
CFLAGS = $(INCLUDES) -Wno-int-conversion -Wno-implicit-function-declaration -Wno-discarded-qualifiers
CXXFLAGS = $(INCLUDES) -DRV1106_1103
LDFLAGS ?=  -L $(RK_APP_MEDIA_LIBS_PATH) -lpthread -lrockit -lrockchip_mpp -lrga -lm -g -O2 -L $(CURRENT_DIR)/lib -lrknnmrt
BIN 	= kvm_video

#Collect the files to compile
MAINSRC = $(wildcard ./*.c) 
CSRCS   = osd/overlay.c npu/src/preprocess.c
CPPSRC  = librga/samples/utils/allocator/dma_alloc.cpp
CXXSRC  = npu/src/yolov5.cc npu/src/postprocess.cc npu/src/yolo_c_api.cc
BUILD_DIR 		= ./build
BUILD_OBJ_DIR 	= $(BUILD_DIR)/obj
BUILD_BIN_DIR 	= $(BUILD_DIR)/bin

OBJEXT 			?= .o

COBJS 			= $(CSRCS:.c=$(OBJEXT))
CPPOBJ 			= $(CPPSRC:.cpp=$(OBJEXT))
MAINOBJ 		= $(MAINSRC:.c=$(OBJEXT))
CXXOBJ			= $(CXXSRC:.cc=$(OBJEXT))

OBJS 			= $(MAINOBJ) $(COBJS) $(CPPOBJ) $(CXXOBJ)
TARGET 			= $(addprefix $(BUILD_OBJ_DIR)/, $(patsubst ./%, %, $(OBJS)))

all: default

$(BUILD_OBJ_DIR)/%.o: %.c
	@mkdir -p $(dir $@)
	@$(CC)  $(CFLAGS) -c $< -o $@ -g -O2
	@echo "CC $<"

$(BUILD_OBJ_DIR)/%.o: %.cpp
	@mkdir -p $(dir $@)
	@$(CC)  $(CFLAGS) -x c -c $< -o $@ -g -O2
	@echo "CC $<"

$(BUILD_OBJ_DIR)/%.o: %.cc
	@mkdir -p $(dir $@)
	@$(CXX)  $(CXXFLAGS) -c $< -o $@ -g -O2
	@echo "CXX $<"
default: $(TARGET)
	@mkdir -p $(dir $(BUILD_BIN_DIR)/)
	$(CXX) -o $(BUILD_BIN_DIR)/$(BIN) $(TARGET) $(LDFLAGS)

clean:
	@echo "clean"
	@rm -rf build
