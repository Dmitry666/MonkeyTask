#include <QApplication>
#include <QQmlApplicationEngine>
#include <QtQml>
#include <QDateTime>

#include <iostream>

#include "filterpropertymodel.h"

void registrationTypes()
{
    qmlRegisterType<FilterPropertyModel>("com.monkey.models", 1, 0, "FilterPropertyModel");
}

void customMessageHandler(QtMsgType type, const QMessageLogContext &context, const QString &msg)
{
    Q_UNUSED(context);

    if (type == QtWarningMsg)
        return;

    QString dt = QDateTime::currentDateTime().toString("dd/MM/yyyy hh:mm:ss");
    QString date = QDateTime::currentDateTime().toString("dd.MM.yyyy");
    QString txt = QString("[%1] ").arg(dt);
    //ConfigureInner &con = ConfigureInner::Instance();

    switch (type)
    {

    case QtDebugMsg: {

        //if (con.log()){
            //ConsoleTextColor color(ConsoleTextColor::ForeGroundWhite);
            txt += QString("[Debug]: %1").arg(msg);
            std::cout << txt.toStdString() << std::endl;
            break;
        //}
    }
#ifndef QT_NO_DEBUG
        txt += QString("[Debug]: %1").arg(msg);
        std::cout << txt.toStdString() << std::endl;
    break;
#else
    return;
#endif
    case QtWarningMsg: {

        //ConsoleTextColor color(ConsoleTextColor::ForeGroundYellow);
#ifndef QT_NO_DEBUG
        txt += QString("[Warning]: %1").arg(msg);
        std::cout << txt.toStdString() << std::endl;
        break;
#else
        return;
#endif
    }
    case QtCriticalMsg: {

        //ConsoleTextColor color(ConsoleTextColor::ForeGroundRed);
        txt += QString("[Critical]: %1").arg(msg);
        std::cout << txt.toStdString() << std::endl;
        break;
    }
    case QtFatalMsg: {

        //ConsoleTextColor color(ConsoleTextColor::ForeGroundRed);
        txt += QString("[Fatal]: %1").arg(msg);
        std::cout << txt.toStdString() << std::endl;
        abort();
        break;
    }
    case QtInfoMsg: {

        //ConsoleTextColor color(ConsoleTextColor::ForeGroundWhite);
        txt += QString("[Info]: %1").arg(msg);
        std::cout << txt.toStdString() << std::endl;
        break;
    }
    default:{
        //ConsoleTextColor color(ConsoleTextColor::ForeGroundWhite);
        txt += QString("[Info]: %1").arg(msg);
        std::cout << txt.toStdString() << std::endl;
        break;
    }
    }
#ifdef QT_NO_DEBUG
    QDir logsDir("logs");
    if (!logsDir.exists()) {
        if (!QDir("./").mkpath("logs")) {
            std::cout << "don't created logs directory." << std::endl;
        }
    }

    QString outPath = "logs/" + date + ".log";
    QFile outFile(outPath);
    if (!outFile.open(QIODevice::WriteOnly | QIODevice::Append)) {
        std::cout << "don't logs file." << std::endl;
    }

    QTextStream textStream(&outFile);
    textStream << txt << "\r\n";
#endif
}


int main(int argc, char *argv[])
{
#ifdef QT_NO_DEBUG
    qInstallMessageHandler(customMessageHandler);
#endif

    QApplication app(argc, argv);

    QQmlApplicationEngine engine;

    registrationTypes();

    engine.load(QUrl(QStringLiteral("qrc:/main.qml")));

    return app.exec();
}
