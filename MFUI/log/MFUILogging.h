/**
 * Copyright (C) 2010 Sopra (support_movalys@sopra.com)
 *
 * This file is part of Movalys MDK.
 * Movalys MDK is free software: you can redistribute it and/or modify
 * it under the terms of the GNU Lesser General Public License as published by
 * the Free Software Foundation, either version 3 of the License, or
 * (at your option) any later version.
 * Movalys MDK is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
 * GNU Lesser General Public License for more details.
 * You should have received a copy of the GNU Lesser General Public License
 * along with Movalys MDK. If not, see <http://www.gnu.org/licenses/>.
 */


#import <MFCore/MFCoreLog.h>

#define MF_UI_LOG_CONTEXT 2

#define MFUILogError(frmt, ...)     LOG_OBJC_MAYBE(LOG_ASYNC_ERROR, ddLogLevel, DDLogLevelError,   MF_UI_LOG_CONTEXT, frmt, ##__VA_ARGS__)
#define MFUILogWarn(frmt, ...)      LOG_OBJC_MAYBE(LOG_ASYNC_WARN, ddLogLevel, DDLogLevelWarning,    MF_UI_LOG_CONTEXT, frmt, ##__VA_ARGS__)
#define MFUILogInfo(frmt, ...)      LOG_OBJC_MAYBE(LOG_ASYNC_INFO, ddLogLevel, DDLogLevelInfo,    MF_UI_LOG_CONTEXT, frmt, ##__VA_ARGS__)
#define MFUILogVerbose(frmt, ...)   LOG_OBJC_MAYBE(LOG_ASYNC_VERBOSE, ddLogLevel, DDLogLevelVerbose, MF_UI_LOG_CONTEXT, frmt, ##__VA_ARGS__)

