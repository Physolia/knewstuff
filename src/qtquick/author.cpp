/*
 * Copyright (C) 2019 Dan Leinir Turthra Jensen <admin@leinir.dk>
 *
 * This library is free software; you can redistribute it and/or
 * modify it under the terms of the GNU Lesser General Public
 * License as published by the Free Software Foundation; either
 * version 2.1 of the License, or (at your option) version 3, or any
 * later version accepted by the membership of KDE e.V. (or its
 * successor approved by the membership of KDE e.V.), which shall
 * act as a proxy defined in Section 6 of version 3 of the license.
 *
 * This library is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
 * Lesser General Public License for more details.
 *
 * You should have received a copy of the GNU Lesser General Public
 * License along with this library.  If not, see <http://www.gnu.org/licenses/>.
 *
 */

#include "author.h"

#include "quickengine.h"

#include "core/author.h"
#include "core/engine.h"
#include "core/provider.h"

#include "knewstuffquick_debug.h"

#include <memory>

namespace KNewStuffQuick {

// This caching will want to eventually go into the Provider level (and be more generalised)
typedef QHash<QString, std::shared_ptr<KNSCore::Author>> AllAuthorsHash;
Q_GLOBAL_STATIC(AllAuthorsHash, allAuthors)

class Author::Private {
public:
    Private(Author *qq)
        : q(qq)
    {}
    Author *q;
    bool componentCompleted{false};
    Engine *engine{nullptr};
    QString providerId;
    QString username;

    QSharedPointer<KNSCore::Provider> provider;
    void resetConnections() {
        if (!componentCompleted) {
            return;
        }
        if (provider) {
            provider->disconnect(q);
        }
        if (engine && engine->engine()) {
            KNSCore::Engine *coreEngine = qobject_cast<KNSCore::Engine*>(engine->engine());
            if (coreEngine) {
                provider = coreEngine->provider(providerId);
            }
            if (!provider) {
                provider = coreEngine->defaultProvider();
            }
        }
        if (provider) {
            connect(provider.get(), &KNSCore::Provider::personLoaded, q, [=](const std::shared_ptr< KNSCore::Author > author){
                allAuthors()->insert(QString::fromLatin1("%1 %2").arg(provider->id()).arg(author->id()), author);
                emit q->dataChanged();
            });
            author(); // Check and make sure...
        }
    }

    std::shared_ptr<KNSCore::Author> author()
    {
        std::shared_ptr<KNSCore::Author> ret;
        if (provider && !username.isEmpty()) {
            ret = allAuthors()->value(QString::fromLatin1("%1 %2").arg(provider->id()).arg(username));
            if(!ret.get()) {
                provider->loadPerson(username);
            }
        }
        return ret;
    }
};
}

using namespace KNewStuffQuick;

Author::Author(QObject *parent)
    : QObject(parent)
    , d(new Private(this))
{
    connect(this, &Author::engineChanged, &Author::dataChanged);
    connect(this, &Author::providerIdChanged, &Author::dataChanged);
    connect(this, &Author::usernameChanged, &Author::dataChanged);
}

Author::~Author()
{
    delete d;
}

void Author::classBegin()
{ }

void Author::componentComplete()
{
    d->componentCompleted = true;
    d->resetConnections();
}

QObject *Author::engine() const
{
    return d->engine;
}

void Author::setEngine(QObject *newEngine)
{
    if (d->engine != newEngine) {
        d->engine = qobject_cast<Engine*>(newEngine);
        d->resetConnections();
        emit engineChanged();
    }
}

QString Author::providerId() const
{
    return d->providerId;
}

void Author::setProviderId(const QString &providerId)
{
    if (d->providerId != providerId) {
        d->providerId = providerId;
        d->resetConnections();
        emit providerIdChanged();
    }
}

QString Author::username() const
{
    return d->username;
}

void Author::setUsername(const QString &username)
{
    if (d->username != username) {
        d->username = username;
        d->resetConnections();
        emit usernameChanged();
    }
}

QString Author::name() const
{
    std::shared_ptr<KNSCore::Author> author = d->author();
    if (author.get() && !author->name().isEmpty()) {
        return author->name();
    }
    return d->username;
}

QString Author::description() const
{
    std::shared_ptr<KNSCore::Author> author = d->author();
    if (author.get()) {
        return author->description();
    }
    return QString{};
}

QString Author::homepage() const
{
    std::shared_ptr<KNSCore::Author> author = d->author();
    if (author.get()) {
        return author->homepage();
    }
    return QString{};
}

QString Author::profilepage() const
{
    std::shared_ptr<KNSCore::Author> author = d->author();
    if (author.get()) {
        return author->profilepage();
    }
    return QString{};
}

QUrl Author::avatarUrl() const
{
    std::shared_ptr<KNSCore::Author> author = d->author();
    if (author.get()) {
        return author->avatarUrl();
    }
    return QUrl{};
}
