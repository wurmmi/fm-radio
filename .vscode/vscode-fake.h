/**
 * @file    vscode-fake.h
 * @author  Michael Wurm <wurm.michael95@gmail.com>
 * @brief   Workaround for cross-compilation in vscode.
 *          Simple #undef some environment variables/defines...
 *          See issue here:
 *            https://github.com/microsoft/vscode-cpptools/issues/1083
 */

#ifndef _VSCODE_FAKE_H_
#define _VSCODE_FAKE_H_

#undef __linux__

#endif // _VSCODE_FAKE_H_
