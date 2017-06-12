#! /usr/bin/env python
# encoding: utf-8

import sys
import os
import time
import optparse
import shutil
import default_const as default



g_current_path = (os.path.split(os.path.realpath(__file__)))[0]
# g_support_rlease_note = False

g_debug = False
g_verbose = True

def main():

    usage = "usage: %prog [-t <target_path>]"
    parser = optparse.OptionParser(usage=usage)
    parser.add_option("-t", "--target_path", action="store", type="string", dest="targetPath", help="Build Target Path", default=default.target_path)
    parser.add_option("-v", action="store_true", dest="verbose")
    parser.add_option("-d", action="store_true", dest="debug")

    (options, args) = parser.parse_args()

    global g_debug
    global g_verbose

    g_debug = options.debug
    g_verbose = options.verbose

    target_path = os.path.abspath(options.targetPath)
    # target_path = '/Users/jiang.duan/WorkSpace/Move-iOS/Move App'
    if not os.path.isdir(target_path):
        print "目标项目路径不对 [ %s ]"%(target_path)
        exit()

    package = Package(target_path)
    package.xcodebuild_list_cmd()
    package.select_code_sign()
    package.perform_package()


class Package(object):
    """docstring for Package"""

    code_sign_identity = default.code_sign_identity
    sdk_version = default.sdk_version
    build_dir = default.build_dir

    bulid_configuration = default.bulid_configuration

    is_workspace = default.is_workspace
    archive_path = default.archive_path
    # when is workspace true
    workspace_name = default.workspace_name
    scheme_name = default.scheme_name
    # when workspace false
    target_name = default.target_name

    archive_file = ""
    ipa_path = "."
    ipa_file = ""

    __target_path = "."

    __targests_lines = []
    __configs_lines = []
    __schemes_lines = []

    def __init__(self, path):
        super(Package, self).__init__()
        self.__target_path = path


    def xcodebuild_list_cmd(self):
        self.__is_workspace()

        cd_cmd_str = "cd '%s'"%self.__target_path
        cmd = "xcodebuild -list"
        information_dir = os.path.abspath("%s/information"%(g_current_path))
        if not os.path.isdir(information_dir):
            os.mkdir(information_dir)
        infofile = os.path.join(information_dir, "list.info")
        log = " > '%s'"%(infofile)
        cmd = cmd + log
        result = os.system("%s;%s"%(cd_cmd_str,cmd))
        if result != 0:
            print "xcodebuild list 失败!!! [%d]"%result
            exit()
        if not os.path.isfile(infofile):
            print "没有生成 xcodebuild list 文件"
            exit()

        f = open(infofile, 'r')
        content = f.read()
        lines = content.split('\n')
        f.close()

        (self.__targests_lines, index) = self.__find_targets_form(lines, 'Targets:')
        lines = lines[index+1:]
        (self.__configs_lines, index) = self.__find_targets_form(lines, 'Build Configurations:')
        lines = lines[index+1:]
        (self.__schemes_lines, index) = self.__find_targets_form(lines, 'Schemes:')

        self.target_name = self.__select_item(self.__targests_lines, 'Targests:')
        self.bulid_configuration = self.__select_item(self.__configs_lines, 'Build Configurations:')
        self.scheme_name = self.__select_item(self.__schemes_lines, 'Schemes:')


    def __is_workspace(self):
        print "\n项目目标目录 [%s]\n"%self.__target_path
        dic = filter(is_find_workspace ,os.listdir(self.__target_path))
        if len(dic) > 0:
            self.is_workspace = True
            self.workspace_name = dic[0][0 : dic[0].find('.xcworkspace')]
        else:
            self.is_workspace = False


    def select_code_sign(self):
        try:
            print "code sign identity:"
            name = raw_input("%s 是否正确? [Y/n]"%(self.code_sign_identity))
            if name != 'Y' and name != 'y' and name != '':
                print "code sign identity 不正确，请修改！"
                print "若不知道正确的code sign identity，可按q，放弃！"
                code_sign = raw_input("请输入正确的 code sign identity :")
                if code_sign == 'q' or code_sign == 'Q':
                    exit()
                self.code_sign_identity = code_sign
        except Exception as e:
            print "输入错误！请输入可选内容！\n"

    def __select_item(self, lines, name):
        for x in xrange(1,10):
            try:
                print name
                for i in range(len(lines)):
                    print "%d. %s"%(i, lines[i])
                input_str = raw_input("请选择 %s "%(name))
                if input_str == 'q' or input_str == 'Q':
                    exit()
                index = int(input_str)
                print "选中 %s \n"%(lines[index])
                return lines[index]
            except Exception as e:
                print "选中错误！请选择可选内容！q健，退出！\n"
        if x >= 10:
            exit()


    def __find_targets_form(self, lines, target_str):
        index_targets = -1
        index_end = len(lines)
        for i in range(len(lines)):
            if lines[i].find(target_str) >= 0:
                index_targets = i
            if lines[i] == '' and index_end == len(lines):
                index_end = i
            if lines[i] == '' and index_end < index_targets:
                index_end = i
        targests_lines = lines[index_targets+1 : index_end]
        targests_lines = map(str_tim , targests_lines)
        return (targests_lines, index_end)

    def perform_package(self):
        self.__path_of_bulid()
        self.__clean_builded_file()
        result = self.clean_project()
        if result != 0:
            print "清除命令执行失败!!! [%d]"%result
            return result
        result = self.bulid_project()
        if result != 0:
            print "编译命令执行失败!!! [%d]"%result
            return result
        result = self.pack_project()
        if result != 0:
            print "打包命令执行失败!!! [%d]"%result
            return result
        print "\n 构建APP IPA文件成功 [%s]\n"%self.ipa_file


    def clean_project(self):
        if self.is_workspace:
            return self.__clean_workspace_cmd()
        else:
            return self.__clean_target_cmd()

    def __clean_target_cmd(self):
        cmd_clean = "xcodebuild -target '%s' -sdk '%s' -configuration %s clean"%(
            self.target_name,
            self.sdk_version,
            self.bulid_configuration)
        print "\n执行清除项目命令: " + cmd_clean
        return self.target_perform_cmd(cmd_clean, "clean")

    def __clean_workspace_cmd(self):
        cmd_clean = "xcodebuild -workspace '%s.xcworkspace' -scheme '%s' -sdk %s -configuration %s clean"%(
            self.workspace_name,
            self.scheme_name,
            self.sdk_version,
            self.bulid_configuration)
        print "\n执行清除项目命令: " + cmd_clean
        return self.target_perform_cmd(cmd_clean, "clean")

    def __path_of_bulid(self):
        project_name = ""
        if self.is_workspace:
            project_name = self.workspace_name
        else:
            project_name = self.target_name
        archive_dir = os.path.abspath("%s/%s"%(g_current_path, self.archive_path))
        self.archive_file = archive_dir + "/%s.xcarchive"%(project_name)
        self.ipa_file = archive_dir + "/%s_%s.ipa"%(project_name, build_time_version())

    def __clean_builded_file(self):
        archive_dir = os.path.abspath("%s/%s"%(g_current_path, self.archive_path))
        if os.path.isdir(archive_dir):
            print "\n删除[%s]文件夹及所有文件 "%archive_dir
            shutil.rmtree(archive_dir)
        information_dir = os.path.abspath("%s/information"%(g_current_path))
        if os.path.isdir(information_dir):
            print "清空[%s]文件夹下所有文件 "%information_dir
            shutil.rmtree(information_dir)
        os.mkdir(information_dir)
        log_dir = os.path.abspath("%s/log"%(g_current_path))
        if os.path.isdir(log_dir):
            print "清空[%s]文件夹下所有文件 "%log_dir
            shutil.rmtree(log_dir)
        os.mkdir(log_dir)


    def bulid_project(self):
        if self.is_workspace:
            return self.__build_workspace_cmd()
        else:
            return self.__build_target_cmd()

    def pack_project(self):
        return self.__pack_cmd()

    def __pack_cmd(self):
        plistpath = self.archive_file + '/Info.plist'
        cmd_pack = "xcodebuild -exportArchive -archivePath '%s' -exportPath '%s' -exportOptionsPlist '%s'"%(
            self.archive_file,
            self.ipa_file,
            plistpath)
        print "\n执行打包项目命令: " + cmd_pack
        return self.target_perform_cmd(cmd_pack, "pack")

    def __build_target_cmd(self):
        cmd_build = "xcodebuild -target '%s' -scheme '%s' -configuration %s -sdk %s archive -archivePath '%s' CODE_SIGN_IDENTITY=\"%s\""%(
            self.target_name,
            self.scheme_name,
            self.bulid_configuration,
            self.sdk_version,
            self.archive_file,
            self.code_sign_identity)
        print "\n执行编译项目命令: " + cmd_build
        return self.target_perform_cmd(cmd_build, "build")

    def __build_workspace_cmd(self):
        cmd_build = "xcodebuild -workspace '%s.xcworkspace' -scheme '%s' -configuration %s -sdk %s archive -archivePath '%s'"%(
            self.workspace_name,
            self.scheme_name,
            self.bulid_configuration,
            self.sdk_version,
            self.archive_file)
        print "\n执行编译项目命令: " + cmd_build
        return self.target_perform_cmd(cmd_build, "build")

    def target_perform_cmd(self, cmd_str, log_str=""):
        cd_cmd_str = "cd '%s'"%self.__target_path
        cmd = cmd_str
        if log_str != "":
            logdir = os.path.abspath("%s/log"%(g_current_path))
            log = " > '%s/%s.log'"%(logdir, log_str)
            error_log = " 2> '%s/%s.error.log'"%(logdir, log_str)
            if not g_debug:
                cmd = cmd + log
            if (not g_verbose) and (not g_debug):
                cmd = cmd + error_log
        return os.system("%s;%s"%(cd_cmd_str,cmd))


def is_find_workspace(str):
    return str.find('.xcworkspace') > 0


def str_tim(str):
    # result = str.replace("\t", '')
    # result = result.replace(" ", '')
    # return result
    return str.strip()


def build_time_version():
    build_time = time.localtime()
    version = "%04d-%02d-%02d-%02d-%02d-%02d"%(
        build_time.tm_year,
        build_time.tm_mon,
        build_time.tm_mday,
        build_time.tm_hour,
        build_time.tm_min,
        build_time.tm_sec)
    return version


if __name__ == '__main__':
    main()
