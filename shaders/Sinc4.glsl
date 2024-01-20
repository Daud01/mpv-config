Copyright 2023 EvET

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the “Software”), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED “AS IS”, WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

#version 330 core

uniform sampler2D inputTexture;
uniform vec2 texelSize;
uniform vec2 screenSize;

out vec4 fragColor;

const int offsetCount = 9;
const float pi = 3.14;

float sincX[offsetCount];
float sincY[offsetCount];

void precomputeSincValues()
{
    float sincOffsetDiv4 = sin(0.25 * pi);
    for (int i = 0; i < offsetCount; i++)
    {
        float offset = (i - offsetCount / 2) * texelSize.x;
        float sincOffset = sin(pi * offset);
        sincX[i] = (sincOffset / (pi * offset)) * (sincOffsetDiv4 / (0.25 * pi * offset));

        offset = (i - offsetCount / 2) * texelSize.y;
        sincOffset = sin(pi * offset);
        sincY[i] = (sincOffset / (pi * offset)) * (sincOffsetDiv4 / (0.25 * pi * offset));
    }
}

void main()
{
    vec2 uv = gl_FragCoord.xy / screenSize;
    
    vec4 color = texture(inputTexture, uv);

    vec4 filteredColor = vec4(0.0);
    float filterSum = 0.0;

    for (int i = 0; i < offsetCount * offsetCount; i++)
    {
        int x = i % offsetCount;
        int y = i / offsetCount;
        vec2 offset = vec2(float(x - offsetCount / 2), float(y - offsetCount / 2)) * texelSize;
        
        float weight = sincX[x] * sincY[y];
        
        filteredColor += color * weight;
        filterSum += weight;
    }
    filteredColor /= filterSum;
    
    fragColor = filteredColor;
}

void main()
{
    precomputeSincValues();
    main();
}
