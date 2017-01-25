/* Copyright 2015 Esri
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *    http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 *
 */

#include <jni.h>

#include <QObject>
#include <QUrl>
#include <QDebug>

#include "QmlApplication.h"

//------------------------------------------------------------------------------

#define kJNIVersion         JNI_VERSION_1_6
#define kJNIClass           "com/arcgis/appframework/QmlApplicationActivity"

//------------------------------------------------------------------------------

static QString qString(JNIEnv *env, jstring jString)
{
    auto string = env->GetStringUTFChars(jString, JNI_FALSE);
    auto qString = QString::fromUtf8(string);
    env->ReleaseStringUTFChars(jString, string);

    return qString;
}

//------------------------------------------------------------------------------

static void consoleLog(JNIEnv *env, jobject /*obj*/, jstring jText)
{
    auto text = env->GetStringUTFChars(jText, JNI_FALSE);

    qDebug() << "JNI:" << text;

    env->ReleaseStringUTFChars(jText, text);
}

//------------------------------------------------------------------------------

static void openUrl(JNIEnv *env, jobject /*obj*/, jstring jUrl)
{
    QUrl url(qString(env, jUrl));

    auto qmlApplication = qobject_cast<QmlApplication*>(QmlApplication::instance());

    qDebug() << Q_FUNC_INFO << url << ":" << qmlApplication;

    if (qmlApplication)
    {
        qmlApplication->openUrl(url);
    }
    else
    {
        QmlApplication::setOpenUrl(url);
    }
}

//------------------------------------------------------------------------------

static JNINativeMethod nativeMethods[] =
{
    {
        "consoleLog",
        "(Ljava/lang/String;)V",
        (void*)consoleLog
    },
    {
        "openUrl",
        "(Ljava/lang/String;)V",
        (void*)openUrl
    }
};

//------------------------------------------------------------------------------

JNIEXPORT jint JNI_OnLoad(JavaVM* vm, void* /*reserved*/)
{
    qDebug() << Q_FUNC_INFO;

    JNIEnv* env;

    if (vm->GetEnv(reinterpret_cast<void**>(&env), kJNIVersion) != JNI_OK)
    {
        qCritical() << Q_FUNC_INFO << "Unable to get JNI environment";
        return JNI_ERR;
    }


    jclass jClass = env->FindClass(kJNIClass);
    if (!jClass)
    {
        qCritical() << Q_FUNC_INFO << kJNIClass " class not found";
        return JNI_ERR;
    }


    if (env->RegisterNatives(jClass, nativeMethods, sizeof(nativeMethods) / sizeof(nativeMethods[0])) < 0)
    {
        qCritical() << Q_FUNC_INFO << "RegisterNatives error";
        return JNI_ERR;
    }

    return kJNIVersion;
}

//------------------------------------------------------------------------------

